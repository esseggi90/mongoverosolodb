FROM mongo:latest

# Installiamo Mongo Express, supervisor e strumenti per debug
RUN apt-get update && apt-get install -y supervisor npm curl netcat-openbsd && \
    npm install -g mongo-express@1.0.0 && \
    mkdir -p /var/log/supervisor /data/db

# Configuriamo permessi per la directory dei dati
RUN chown -R mongodb:mongodb /data/db && chmod -R 755 /data/db

# Creiamo uno script d'avvio per mongo-express con attesa per MongoDB
RUN echo '#!/bin/bash\n\
echo "Waiting for MongoDB to be ready..."\n\
until nc -z localhost 27017; do\n\
  echo "MongoDB not available yet - waiting..."\n\
  sleep 2\n\
done\n\
echo "MongoDB is up - starting mongo-express"\n\
sleep 5\n\
# Configurazione di mongo-express tramite variabili d\'ambiente\n\
export ME_CONFIG_MONGODB_SERVER=localhost\n\
export ME_CONFIG_MONGODB_PORT=27017\n\
export ME_CONFIG_MONGODB_ADMINUSERNAME=admin\n\
export ME_CONFIG_MONGODB_ADMINPASSWORD=password\n\
export ME_CONFIG_BASICAUTH_USERNAME=admin\n\
export ME_CONFIG_BASICAUTH_PASSWORD=password\n\
export ME_CONFIG_MONGODB_AUTH_DATABASE=admin\n\
export ME_CONFIG_SITE_BASEURL=/\n\
export ME_CONFIG_OPTIONS_EDITORTHEME="ambiance"\n\
export ME_CONFIG_MONGODB_AUTH_USERNAME=admin\n\
export ME_CONFIG_MONGODB_AUTH_PASSWORD=password\n\
export ME_CONFIG_MONGODB_ENABLE_ADMIN=true\n\
export ME_CONFIG_SITE_SESSIONPASSWORD=superSecret\n\
# Avviamo mongo-express con parametri specifici\n\
/usr/local/bin/mongo-express --port 8081 --host 0.0.0.0\n'\
> /usr/local/bin/start-mongo-express.sh && \
chmod +x /usr/local/bin/start-mongo-express.sh

# Creiamo uno script per avviare MongoDB con debug
RUN echo '#!/bin/bash\n\
echo "Starting MongoDB with debug..."\n\
echo "Directory /data/db contents:"\n\
ls -la /data/db\n\
echo "Starting mongod..."\n\
mongod --dbpath=/data/db --bind_ip_all --port 27017 --logpath=/var/log/supervisor/mongodb_debug.log --logappend\n'\
> /usr/local/bin/start-mongodb.sh && \
chmod +x /usr/local/bin/start-mongodb.sh

# Creiamo uno script per esporre una semplice pagina HTTP
RUN echo '#!/bin/bash\n\
echo "Starting simple HTTP server on port 80..."\n\
echo "<html><body><h1>MongoDB Server is running</h1><p>Use port 8081 for Mongo Express interface</p></body></html>" > /tmp/index.html\n\
cd /tmp && python3 -m http.server 80\n'\
> /usr/local/bin/simple-http.sh && \
chmod +x /usr/local/bin/simple-http.sh

# Copiamo i file di configurazione
COPY mongo-init.js /docker-entrypoint-initdb.d/

# Configurazione di supervisord
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "logfile=/var/log/supervisor/supervisord.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "logfile_maxbytes=50MB" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:mongodb]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/local/bin/start-mongodb.sh" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "priority=10" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/mongodb.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/mongodb_error.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:mongo-express]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/local/bin/start-mongo-express.sh" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "priority=20" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/mongo-express.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/mongo-express_error.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:http-server]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/local/bin/simple-http.sh" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "priority=30" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/http-server.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/http-server_error.log" >> /etc/supervisor/conf.d/supervisord.conf

# Esponiamo le porte per MongoDB, Mongo Express e HTTP
EXPOSE 27017 8081 80

# Avviamo supervisord per gestire tutti i servizi
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
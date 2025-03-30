FROM mongo:latest

# Installiamo Mongo Express, supervisor e strumenti per debug
RUN apt-get update && apt-get install -y supervisor npm curl netcat-openbsd && \
    npm install -g mongo-express && \
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
exec /usr/local/bin/mongo-express\n'\
> /usr/local/bin/start-mongo-express.sh && \
chmod +x /usr/local/bin/start-mongo-express.sh

# Creiamo uno script per avviare MongoDB con debug
RUN echo '#!/bin/bash\n\
echo "Starting MongoDB with debug..."\n\
ls -la /data/db\n\
mongod --dbpath=/data/db --bind_ip_all --logpath=/var/log/supervisor/mongodb_debug.log --logappend\n'\
> /usr/local/bin/start-mongodb.sh && \
chmod +x /usr/local/bin/start-mongodb.sh

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
    echo "environment=ME_CONFIG_MONGODB_SERVER=\"localhost\",ME_CONFIG_MONGODB_PORT=\"27017\",ME_CONFIG_MONGODB_ADMINUSERNAME=\"admin\",ME_CONFIG_MONGODB_ADMINPASSWORD=\"password\",ME_CONFIG_BASICAUTH_USERNAME=\"admin\",ME_CONFIG_BASICAUTH_PASSWORD=\"password\",ME_CONFIG_MONGODB_AUTH_DATABASE=\"admin\",ME_CONFIG_SITE_BASEURL=\"/\"" >> /etc/supervisor/conf.d/supervisord.conf

# Esponiamo le porte per MongoDB e Mongo Express
EXPOSE 27017 8081

# Avviamo supervisord per gestire MongoDB e Mongo Express
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
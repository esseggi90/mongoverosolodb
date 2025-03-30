FROM mongo:latest

# Installiamo Mongo Express, supervisor e strumenti per debug
RUN apt-get update && apt-get install -y supervisor npm curl netcat-openbsd nginx && \
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
export ME_CONFIG_SITE_BASEURL=/mongo-express/\n\
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

# Configurazione di nginx come proxy per mongo-express
RUN echo 'server {\n\
    listen 80;\n\
    server_name localhost;\n\
\n\
    # Pagina principale\n\
    location / {\n\
        root /var/www/html;\n\
        index index.html;\n\
    }\n\
\n\
    # Proxy per Mongo Express\n\
    location /mongo-express/ {\n\
        proxy_pass http://localhost:8081/;\n\
        proxy_http_version 1.1;\n\
        proxy_set_header Upgrade $http_upgrade;\n\
        proxy_set_header Connection "upgrade";\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
        proxy_set_header X-Forwarded-Proto $scheme;\n\
    }\n\
}\n' > /etc/nginx/sites-available/default

# Creiamo la pagina principale
RUN mkdir -p /var/www/html && \
    echo '<html>\n\
<head>\n\
    <title>MongoDB Server</title>\n\
    <style>\n\
        body { font-family: Arial, sans-serif; margin: 0; padding: 30px; }\n\
        .container { max-width: 800px; margin: 0 auto; }\n\
        h1 { color: #4CAF50; }\n\
        .card { background: #f9f9f9; border-radius: 5px; padding: 20px; margin-top: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }\n\
        a.button { display: inline-block; background: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 15px; }\n\
    </style>\n\
</head>\n\
<body>\n\
    <div class="container">\n\
        <h1>MongoDB Server is running</h1>\n\
        <div class="card">\n\
            <h2>MongoDB</h2>\n\
            <p>MongoDB is running on port 27017.</p>\n\
            <p>Connection string: <code>mongodb://mangando_user:mangando_password@hostname:27017/mangando</code></p>\n\
        </div>\n\
        <div class="card">\n\
            <h2>Mongo Express</h2>\n\
            <p>Access the MongoDB web interface:</p>\n\
            <a href="/mongo-express/" class="button">Open Mongo Express</a>\n\
            <p>Credentials:<br>Username: <code>admin</code><br>Password: <code>password</code></p>\n\
        </div>\n\
    </div>\n\
</body>\n\
</html>' > /var/www/html/index.html

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
    echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=nginx -g 'daemon off;'" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "priority=30" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/var/log/supervisor/nginx.log" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/var/log/supervisor/nginx_error.log" >> /etc/supervisor/conf.d/supervisord.conf

# Esponiamo le porte per MongoDB, Mongo Express e HTTP
EXPOSE 27017 8081 80

# Avviamo supervisord per gestire tutti i servizi
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
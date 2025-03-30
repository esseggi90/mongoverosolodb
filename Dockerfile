FROM mongo:latest

# Installiamo Mongo Express e supervisor per gestire più processi
RUN apt-get update && apt-get install -y supervisor npm && \
    npm install -g mongo-express && \
    mkdir -p /var/log/supervisor

# Copiamo i file di configurazione
COPY mongo-init.js /docker-entrypoint-initdb.d/

# Configurazione di supervisord
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:mongodb]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=mongod --setParameter featureCompatibilityVersion=7.0 --setParameter vectorSearchEnabled=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:mongo-express]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/local/bin/mongo-express" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "environment=ME_CONFIG_MONGODB_SERVER=\"localhost\",ME_CONFIG_MONGODB_PORT=\"27017\",ME_CONFIG_MONGODB_ADMINUSERNAME=\"admin\",ME_CONFIG_MONGODB_ADMINPASSWORD=\"password\",ME_CONFIG_BASICAUTH_USERNAME=\"admin\",ME_CONFIG_BASICAUTH_PASSWORD=\"password\"" >> /etc/supervisor/conf.d/supervisord.conf

# Esponiamo le porte per MongoDB e Mongo Express
EXPOSE 27017 8081

# Avviamo supervisord per gestire MongoDB e Mongo Express
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
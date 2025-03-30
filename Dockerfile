FROM mongo:6.0

# Create directory for MongoDB data and SSL certificates
RUN mkdir -p /data/db /var/log/mongodb /etc/mongodb/ssl

# Create self-signed certificate
RUN apt-get update && apt-get install -y openssl && \
    openssl req -newkey rsa:2048 -new -x509 -days 3650 -nodes \
    -out /etc/mongodb/ssl/mongodb.crt \
    -keyout /etc/mongodb/ssl/mongodb.key \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=mongodb" && \
    cat /etc/mongodb/ssl/mongodb.key /etc/mongodb/ssl/mongodb.crt > /etc/mongodb/ssl/mongodb.pem && \
    chmod 600 /etc/mongodb/ssl/mongodb.pem /etc/mongodb/ssl/mongodb.key

# Copy configuration file
COPY ./config/mongod.conf /etc/mongod.conf

# Copy the initialization script
COPY ./scripts/init-mongo.js /docker-entrypoint-initdb.d/

# Copy other scripts but don't place them in the initialization directory
COPY ./scripts/backup-restore.sh /usr/local/bin/
COPY ./scripts/healthcheck.js /usr/local/bin/
COPY ./scripts/update-connection.js /usr/local/bin/

# Make scripts executable
RUN chmod +x /usr/local/bin/backup-restore.sh

# Expose the MongoDB port
EXPOSE 27017

# Set environment variables
ENV MONGO_INITDB_DATABASE=mangandoDB

# Command to run MongoDB with configuration and SSL
CMD ["mongod", "--config", "/etc/mongod.conf", "--tlsMode", "allowTLS", "--tlsCertificateKeyFile", "/etc/mongodb/ssl/mongodb.pem"] 
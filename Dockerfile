FROM mongo:6.0

# Create directory for MongoDB data and SSL certificates
RUN mkdir -p /data/db /var/log/mongodb /etc/mongodb/ssl

# Create CA and server certificates properly
RUN apt-get update && apt-get install -y openssl && \
    # Create CA key and certificate
    openssl genrsa -out /etc/mongodb/ssl/ca.key 4096 && \
    openssl req -new -x509 -days 3650 -key /etc/mongodb/ssl/ca.key \
        -out /etc/mongodb/ssl/ca.crt \
        -subj "/C=US/ST=State/L=City/O=MongoDB CA/CN=MongoDB Root CA" && \
    # Create server key and CSR
    openssl genrsa -out /etc/mongodb/ssl/mongodb.key 2048 && \
    openssl req -new -key /etc/mongodb/ssl/mongodb.key \
        -out /etc/mongodb/ssl/mongodb.csr \
        -subj "/C=US/ST=State/L=City/O=MongoDB Server/CN=mongodb" && \
    # Sign server certificate with CA
    openssl x509 -req -in /etc/mongodb/ssl/mongodb.csr \
        -CA /etc/mongodb/ssl/ca.crt \
        -CAkey /etc/mongodb/ssl/ca.key \
        -CAcreateserial \
        -out /etc/mongodb/ssl/mongodb.crt \
        -days 3650 && \
    # Create PEM file (server cert + key)
    cat /etc/mongodb/ssl/mongodb.key /etc/mongodb/ssl/mongodb.crt > /etc/mongodb/ssl/mongodb.pem && \
    # Set permissions
    chmod 600 /etc/mongodb/ssl/mongodb.pem /etc/mongodb/ssl/mongodb.key /etc/mongodb/ssl/ca.key && \
    chmod 644 /etc/mongodb/ssl/ca.crt /etc/mongodb/ssl/mongodb.crt

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
CMD ["mongod", "--config", "/etc/mongod.conf", "--tlsMode", "allowTLS", "--tlsCertificateKeyFile", "/etc/mongodb/ssl/mongodb.pem", "--tlsCAFile", "/etc/mongodb/ssl/ca.crt"] 
FROM mongo:6.0

# Create directory for MongoDB data
RUN mkdir -p /data/db /var/log/mongodb

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

# Command to run MongoDB with configuration
CMD ["mongod", "--config", "/etc/mongod.conf"] 
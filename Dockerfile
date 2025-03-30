FROM mongo:6.0

# Create directory for MongoDB data
RUN mkdir -p /data/db

# Copy configuration file
COPY ./config/mongod.conf /etc/mongod.conf

# Copy initialization scripts
COPY ./scripts/ /docker-entrypoint-initdb.d/

# Expose the MongoDB port
EXPOSE 27017

# Set environment variables
ENV MONGO_INITDB_DATABASE=mangandoDB

# Command to run MongoDB with configuration
CMD ["mongod", "--config", "/etc/mongod.conf"] 
# Use the official MongoDB image as the base image
FROM mongo:latest

# Set environment variables
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=admin123
ENV MONGO_INITDB_DATABASE=mydatabase

# Copy the initialization script to the docker-entrypoint-initdb.d directory
COPY init-db.js /docker-entrypoint-initdb.d/

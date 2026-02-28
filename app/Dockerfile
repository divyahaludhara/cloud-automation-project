# Use Ubuntu as base image
FROM ubuntu:22.04

# Install Python for testing
RUN apt-get update && apt-get install -y python3 python3-pip

# Copy app files
COPY . /app
WORKDIR /app

# Expose port 80
EXPOSE 80

# Run simple HTTP server
CMD ["python3", "-m", "http.server", "80"]
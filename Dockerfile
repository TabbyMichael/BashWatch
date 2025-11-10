# Use Alpine Linux as base image for minimal size
FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    bash \
    coreutils \
    procps \
    util-linux \
    && rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /app

# Copy project files
COPY . .

# Make scripts executable
RUN chmod +x bin/*.sh lib/*.sh tests/*.sh

# Create logs directory
RUN mkdir -p logs

# Default command
CMD ["./bin/sysmon.sh"]
#!/bin/bash

# Initialization script for BashWatch

# Create logs directory if it doesn't exist
mkdir -p ../logs

# Set up logging
LOG_FILE="../logs/sysmon.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Log initialization
log_message "BashWatch initialized"

echo "BashWatch initialized successfully"
echo "Log file: $LOG_FILE"
#!/bin/bash

# Utility functions for BashWatch

# Function to log messages
log_message() {
    local message="$1"
    # Create logs directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    local message="$1"
    log_message "ERROR: $message"
    echo "Error: $message" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to format bytes into human readable format
format_bytes() {
    local bytes=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local unit_index=0
    
    while (( bytes > 1024 && unit_index < 4 )); do
        bytes=$((bytes / 1024))
        ((unit_index++))
    done
    
    echo "${bytes} ${units[$unit_index]}"
}
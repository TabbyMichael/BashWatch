#!/bin/bash

# Utility functions for BashWatch

# Function to log messages
log_message() {
    local message="$1"
    # Create logs directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Rotate logs if needed (check every 100 log entries)
    local log_count_file="${LOG_FILE}.count"
    local count=0
    
    if [[ -f "$log_count_file" ]]; then
        count=$(cat "$log_count_file" 2>/dev/null || echo 0)
    fi
    
    count=$((count + 1))
    echo "$count" > "$log_count_file"
    
    if [[ $((count % 100)) -eq 0 ]]; then
        rotate_logs "$LOG_FILE" "$LOG_ROTATION_SIZE"
    fi
    
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

# Function to rotate logs when they exceed a certain size
rotate_logs() {
    local log_file="$1"
    local max_size="${2:-10485760}"  # Default 10MB
    
    # Check if log file exists and get its size
    if [[ -f "$log_file" ]]; then
        local file_size=$(stat -c %s "$log_file" 2>/dev/null || echo 0)
        
        # If file size exceeds max_size, rotate it
        if [[ "$file_size" -gt "$max_size" ]]; then
            local timestamp=$(date '+%Y%m%d_%H%M%S')
            local rotated_file="${log_file}.${timestamp}"
            
            # Move current log to rotated name
            mv "$log_file" "$rotated_file"
            
            # Create new empty log file
            touch "$log_file"
            
            # Compress rotated file
            gzip "$rotated_file" 2>/dev/null || true
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Log rotated: ${rotated_file}.gz" >> "$log_file"
        fi
    fi
}

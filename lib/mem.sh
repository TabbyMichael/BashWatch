#!/bin/bash

# Memory monitoring functions

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
UTILS_FILE="$PROJECT_DIR/lib/utils.sh"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

# Function to get memory usage
get_memory_usage() {
    if command_exists "free"; then
        free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }'
    else
        echo "0%"
    fi
}

# Function to get memory info
get_memory_info() {
    if command_exists "free"; then
        local mem_info=$(free -h)
        local mem_total=$(echo "$mem_info" | awk 'NR==2{print $2}')
        local mem_used=$(echo "$mem_info" | awk 'NR==2{print $3}')
        echo "$mem_used / $mem_total"
    else
        echo "Unknown"
    fi
}

# Function to get swap usage
get_swap_usage() {
    if command_exists "free"; then
        free -m | awk 'NR==3{if($2>0){printf "%.2f%%", $3*100/$2} else {print "0%"}}'
    else
        echo "0%"
    fi
}
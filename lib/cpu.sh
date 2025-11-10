#!/bin/bash

# CPU monitoring functions

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
UTILS_FILE="$PROJECT_DIR/lib/utils.sh"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

# Function to get CPU usage
get_cpu_usage() {
    if command_exists "top"; then
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
    elif command_exists "vmstat"; then
        vmstat 1 2 | tail -1 | awk '{print 100-$15"%"}'
    else
        echo "0"
    fi
}

# Function to get CPU load average
get_cpu_load() {
    if [[ -f /proc/loadavg ]]; then
        awk '{print $1" "$2" "$3}' /proc/loadavg
    else
        echo "N/A"
    fi
}

# Function to get CPU information
get_cpu_info() {
    if [[ -f /proc/cpuinfo ]]; then
        grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
    else
        echo "Unknown CPU"
    fi
}
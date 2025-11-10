#!/bin/bash

# Network monitoring functions

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
UTILS_FILE="$PROJECT_DIR/lib/utils.sh"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

# Function to get network statistics
get_network_stats() {
    if command_exists "ifstat"; then
        ifstat -n -w 1 1 | tail -n +3
    elif [[ -f /proc/net/dev ]]; then
        # Read from /proc/net/dev
        grep -E "^[a-z]" /proc/net/dev | awk '{print $1 ":", $2 " bytes received,", $10 " bytes transmitted"}'
    else
        echo "No network data available"
    fi
}

# Function to get active network interfaces
get_active_interfaces() {
    if command_exists "ip"; then
        ip link show | awk '/state UP/ {print $2}' | sed 's/://'
    elif command_exists "ifconfig"; then
        ifconfig | awk '/RUNNING/ {print $1}' | sed 's/://'
    else
        echo "lo"  # fallback to loopback
    fi
}

# Function to get network traffic
get_network_traffic() {
    local interface=${1:-$(get_active_interfaces | head -1)}
    if [[ -f /proc/net/dev ]]; then
        grep "^$interface:" /proc/net/dev | awk '{print $2, $10}'
    else
        echo "0 0"
    fi
}
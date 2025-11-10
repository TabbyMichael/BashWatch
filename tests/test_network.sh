#!/bin/bash

# Test script for Network monitoring functions

# Source the network module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NET_MODULE="$PROJECT_DIR/lib/net.sh"

if [[ -f "$NET_MODULE" ]]; then
    source "$NET_MODULE"
else
    echo "ERROR: Network module not found: $NET_MODULE"
    exit 1
fi

# Test functions
echo "Testing Network monitoring functions..."
echo "======================================"

echo "Active Interfaces:"
active_interfaces=$(get_active_interfaces)
echo "$active_interfaces"

echo -e "\nNetwork Stats:"
network_stats=$(get_network_stats)
echo "$network_stats"

echo -e "\nAll tests completed successfully!"
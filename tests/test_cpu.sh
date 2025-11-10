#!/bin/bash

# Test script for CPU monitoring functions

# Source the CPU module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CPU_MODULE="$PROJECT_DIR/lib/cpu.sh"

if [[ -f "$CPU_MODULE" ]]; then
    source "$CPU_MODULE"
else
    echo "ERROR: CPU module not found: $CPU_MODULE"
    exit 1
fi

# Test functions
echo "Testing CPU monitoring functions..."
echo "==================================="

echo "CPU Usage:"
cpu_usage=$(get_cpu_usage)
echo "$cpu_usage"

echo -e "\nCPU Load:"
cpu_load=$(get_cpu_load)
echo "$cpu_load"

echo -e "\nCPU Info:"
cpu_info=$(get_cpu_info)
echo "$cpu_info"

echo -e "\nAll tests completed successfully!"
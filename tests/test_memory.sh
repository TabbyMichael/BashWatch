#!/bin/bash

# Test script for Memory monitoring functions

# Source the memory module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MEM_MODULE="$PROJECT_DIR/lib/mem.sh"

if [[ -f "$MEM_MODULE" ]]; then
    source "$MEM_MODULE"
else
    echo "ERROR: Memory module not found: $MEM_MODULE"
    exit 1
fi

# Test functions
echo "Testing Memory monitoring functions..."
echo "======================================"

echo "Memory Usage:"
memory_usage=$(get_memory_usage)
echo "$memory_usage"

echo -e "\nMemory Info:"
memory_info=$(get_memory_info)
echo "$memory_info"

echo -e "\nSwap Usage:"
swap_usage=$(get_swap_usage)
echo "$swap_usage"

echo -e "\nAll tests completed successfully!"
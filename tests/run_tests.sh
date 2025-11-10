#!/bin/bash

# Test runner for BashWatch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running BashWatch Tests"
echo "======================="

# Run CPU tests
echo "1. Running CPU tests..."
"$SCRIPT_DIR/test_cpu.sh"
if [[ $? -eq 0 ]]; then
    echo "✓ CPU tests passed"
else
    echo "✗ CPU tests failed"
fi

echo ""

# Run Memory tests
echo "2. Running Memory tests..."
"$SCRIPT_DIR/test_memory.sh"
if [[ $? -eq 0 ]]; then
    echo "✓ Memory tests passed"
else
    echo "✗ Memory tests failed"
fi

echo ""

# Run Network tests
echo "3. Running Network tests..."
"$SCRIPT_DIR/test_network.sh"
if [[ $? -eq 0 ]]; then
    echo "✓ Network tests passed"
else
    echo "✗ Network tests failed"
fi

echo ""
echo "Test run completed!"
#!/bin/bash

# Source the main script to get the variables
source bin/sysmon.sh

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "PROJECT_DIR: $PROJECT_DIR"
echo "LOG_FILE: $LOG_FILE"
echo "LOG_FILE dirname: $(dirname "$LOG_FILE")"
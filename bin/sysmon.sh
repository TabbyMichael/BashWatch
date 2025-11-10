#!/bin/bash

# sysmon.sh - Main system monitoring script

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Set default log file path
LOG_FILE="$PROJECT_DIR/logs/sysmon.log"

# Source utility functions first to ensure log_message is available
UTILS_FILE="$PROJECT_DIR/lib/utils.sh"
if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

# Source configuration
CONFIG_FILE="$PROJECT_DIR/config/sysmon.conf"

# Function to load configuration
load_config() {
    local config_path="$1"
    if [[ -f "$config_path" ]]; then
        # Validate config file
        if [[ -r "$config_path" ]]; then
            source "$config_path"
            log_message "Configuration loaded from $config_path"
        else
            error_exit "Cannot read configuration file: $config_path"
        fi
    else
        log_message "Configuration file not found, using defaults"
    fi
}

# Load default configuration
load_config "$CONFIG_FILE"

# Source monitoring modules
CPU_MODULE="$PROJECT_DIR/lib/cpu.sh"
if [[ -f "$CPU_MODULE" ]]; then
    source "$CPU_MODULE"
fi

MEM_MODULE="$PROJECT_DIR/lib/mem.sh"
if [[ -f "$MEM_MODULE" ]]; then
    source "$MEM_MODULE"
fi

NET_MODULE="$PROJECT_DIR/lib/net.sh"
if [[ -f "$NET_MODULE" ]]; then
    source "$NET_MODULE"
fi

# Set default values if not configured
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/logs/sysmon.log}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"
DAEMON_MODE="${DAEMON_MODE:-false}"

# Trap for cleanup on exit
trap cleanup EXIT
trap cleanup INT

# Function to clean up resources
cleanup() {
    log_message "BashWatch shutting down"
    exit 0
}

# Function to display help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

System monitoring tool written in Bash.

Options:
    -h, --help          Show this help message
    -v, --version       Show version information
    -c, --config FILE   Use specific configuration file
    -j, --json          Output in JSON format
    -d, --daemon        Run in daemon mode with continuous monitoring
    --cpu               Monitor CPU only
    --memory            Monitor memory only
    --network           Monitor network only

Examples:
    $0                  # Run with default settings
    $0 --json           # Output in JSON format
    $0 --daemon         # Run in continuous monitoring mode
    $0 --config /path/to/config.conf  # Use custom config
EOF
}

# Function to display version
show_version() {
    echo "BashWatch System Monitor v0.1.0"
}

# Function to monitor CPU
monitor_cpu() {
    log_message "Monitoring CPU"
    
    cpu_usage=$(get_cpu_usage)
    cpu_load=$(get_cpu_load)
    cpu_info=$(get_cpu_info)
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "{\"cpu_usage\": \"$cpu_usage\", \"cpu_load\": \"$cpu_load\", \"cpu_info\": \"$cpu_info\"}"
    else
        echo "CPU Usage: $cpu_usage"
        echo "CPU Load: $cpu_load"
        echo "CPU Info: $cpu_info"
    fi
}

# Function to monitor memory
monitor_memory() {
    log_message "Monitoring Memory"
    
    memory_usage=$(get_memory_usage)
    memory_info=$(get_memory_info)
    swap_usage=$(get_swap_usage)
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "{\"memory_usage\": \"$memory_usage\", \"memory_info\": \"$memory_info\", \"swap_usage\": \"$swap_usage\"}"
    else
        echo "Memory Usage: $memory_usage"
        echo "Memory Info: $memory_info"
        echo "Swap Usage: $swap_usage"
    fi
}

# Function to monitor network
monitor_network() {
    log_message "Monitoring Network"
    
    network_stats=$(get_network_stats)
    active_interfaces=$(get_active_interfaces)
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "{\"active_interfaces\": \"$active_interfaces\", \"network_stats\": \"$network_stats\"}"
    else
        echo "Active Interfaces: $active_interfaces"
        echo "Network Stats:"
        echo "$network_stats"
    fi
}

# Function to check thresholds and send alerts
check_thresholds() {
    # Check CPU threshold
    cpu_usage=$(get_cpu_usage)
    # Remove % sign and compare
    cpu_value=${cpu_usage%\%}
    if [[ -n "$cpu_value" && "$cpu_value" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$cpu_value > $CPU_THRESHOLD" | bc -l) )); then
        alert_message "CPU usage ($cpu_usage) exceeded threshold ($CPU_THRESHOLD%)"
    fi
    
    # Check Memory threshold
    memory_usage=$(get_memory_usage)
    # Remove % sign and compare
    memory_value=${memory_usage%\%}
    if [[ -n "$memory_value" && "$memory_value" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$memory_value > $MEMORY_THRESHOLD" | bc -l) )); then
        alert_message "Memory usage ($memory_usage) exceeded threshold ($MEMORY_THRESHOLD%)"
    fi
}

# Function to send alert messages
alert_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_msg="[$timestamp] ALERT: $message"
    
    # Log the alert
    echo "$alert_msg" >> "${PROJECT_DIR}/logs/sysmon.alerts"
    
    # Also output to console if not in JSON mode
    if [[ "$OUTPUT_FORMAT" != "json" ]]; then
        echo "$alert_msg" >&2
    fi
}

# Function for continuous monitoring (daemon mode)
monitor_continuous() {
    log_message "Starting continuous monitoring mode"
    
    # Handle SIGINT and SIGTERM for graceful shutdown
    trap 'log_message "Received interrupt signal"; exit 0' INT TERM
    
    echo "BashWatch Daemon Mode - Continuous Monitoring Started"
    echo "Press Ctrl+C to stop"
    
    while true; do
        # Current timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        if [[ "$OUTPUT_FORMAT" != "json" ]]; then
            echo -e "\n=== System Status at $timestamp ==="
        fi
        
        # Run all monitoring functions
        if [[ "$ENABLE_CPU_MONITORING" == "true" ]]; then
            monitor_cpu
        fi
        
        if [[ "$ENABLE_MEMORY_MONITORING" == "true" ]]; then
            monitor_memory
        fi
        
        if [[ "$ENABLE_NETWORK_MONITORING" == "true" ]]; then
            monitor_network
        fi
        
        # Check thresholds for alerts
        check_thresholds
        
        # Wait for the shortest interval
        local sleep_time=$CPU_INTERVAL
        if [[ -z "$sleep_time" || "$NETWORK_INTERVAL" -lt "$sleep_time" ]]; then
            sleep_time=$NETWORK_INTERVAL
        fi
        if [[ -z "$sleep_time" || "$MEMORY_INTERVAL" -lt "$sleep_time" ]]; then
            sleep_time=$MEMORY_INTERVAL
        fi
        
        # Default to 5 seconds if no interval set
        sleep_time=${sleep_time:-5}
        
        if [[ "$OUTPUT_FORMAT" != "json" ]]; then
            echo -e "\nNext update in $sleep_time seconds..."
        fi
        
        sleep "$sleep_time"
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            load_config "$CONFIG_FILE"
            shift 2
            ;;
        -j|--json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        -d|--daemon)
            DAEMON_MODE="true"
            shift
            ;;
        --cpu)
            monitor_cpu
            exit 0
            ;;
        --memory)
            monitor_memory
            exit 0
            ;;
        --network)
            monitor_network
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
log_message "Starting BashWatch system monitor"

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

if [[ "$DAEMON_MODE" == "true" ]]; then
    monitor_continuous
else
    # Run all monitoring functions
    if [[ "$ENABLE_CPU_MONITORING" == "true" ]]; then
        monitor_cpu
    fi
    
    if [[ "$ENABLE_MEMORY_MONITORING" == "true" ]]; then
        monitor_memory
    fi
    
    if [[ "$ENABLE_NETWORK_MONITORING" == "true" ]]; then
        monitor_network
    fi
    
    log_message "BashWatch system monitor completed"
fi
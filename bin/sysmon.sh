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
            validate_config
        else
            error_exit "Cannot read configuration file: $config_path"
        fi
    else
        log_message "Configuration file not found, using defaults"
    fi
}

# Function to validate configuration parameters
validate_config() {
    # Validate CPU_INTERVAL
    if [[ -n "$CPU_INTERVAL" && ! "$CPU_INTERVAL" =~ ^[0-9]+$ ]]; then
        log_message "WARNING: Invalid CPU_INTERVAL value '$CPU_INTERVAL', using default value 5"
        CPU_INTERVAL=5
    elif [[ -n "$CPU_INTERVAL" && "$CPU_INTERVAL" -lt 1 ]]; then
        log_message "WARNING: CPU_INTERVAL value '$CPU_INTERVAL' is too low, using minimum value 1"
        CPU_INTERVAL=1
    fi
    
    # Validate MEMORY_INTERVAL
    if [[ -n "$MEMORY_INTERVAL" && ! "$MEMORY_INTERVAL" =~ ^[0-9]+$ ]]; then
        log_message "WARNING: Invalid MEMORY_INTERVAL value '$MEMORY_INTERVAL', using default value 5"
        MEMORY_INTERVAL=5
    elif [[ -n "$MEMORY_INTERVAL" && "$MEMORY_INTERVAL" -lt 1 ]]; then
        log_message "WARNING: MEMORY_INTERVAL value '$MEMORY_INTERVAL' is too low, using minimum value 1"
        MEMORY_INTERVAL=1
    fi
    
    # Validate NETWORK_INTERVAL
    if [[ -n "$NETWORK_INTERVAL" && ! "$NETWORK_INTERVAL" =~ ^[0-9]+$ ]]; then
        log_message "WARNING: Invalid NETWORK_INTERVAL value '$NETWORK_INTERVAL', using default value 10"
        NETWORK_INTERVAL=10
    elif [[ -n "$NETWORK_INTERVAL" && "$NETWORK_INTERVAL" -lt 1 ]]; then
        log_message "WARNING: NETWORK_INTERVAL value '$NETWORK_INTERVAL' is too low, using minimum value 1"
        NETWORK_INTERVAL=1
    fi
    
    # Validate CPU_THRESHOLD
    if [[ -n "$CPU_THRESHOLD" && ! "$CPU_THRESHOLD" =~ ^[0-9]+$ ]]; then
        log_message "WARNING: Invalid CPU_THRESHOLD value '$CPU_THRESHOLD', using default value 80"
        CPU_THRESHOLD=80
    elif [[ -n "$CPU_THRESHOLD" && ("$CPU_THRESHOLD" -lt 0 || "$CPU_THRESHOLD" -gt 100) ]]; then
        log_message "WARNING: CPU_THRESHOLD value '$CPU_THRESHOLD' is out of range (0-100), using default value 80"
        CPU_THRESHOLD=80
    fi
    
    # Validate MEMORY_THRESHOLD
    if [[ -n "$MEMORY_THRESHOLD" && ! "$MEMORY_THRESHOLD" =~ ^[0-9]+$ ]]; then
        log_message "WARNING: Invalid MEMORY_THRESHOLD value '$MEMORY_THRESHOLD', using default value 85"
        MEMORY_THRESHOLD=85
    elif [[ -n "$MEMORY_THRESHOLD" && ("$MEMORY_THRESHOLD" -lt 0 || "$MEMORY_THRESHOLD" -gt 100) ]]; then
        log_message "WARNING: MEMORY_THRESHOLD value '$MEMORY_THRESHOLD' is out of range (0-100), using default value 85"
        MEMORY_THRESHOLD=85
    fi
    
    # Validate ENABLE_* flags
    if [[ -n "$ENABLE_CPU_MONITORING" && ! "$ENABLE_CPU_MONITORING" =~ ^(true|false)$ ]]; then
        log_message "WARNING: Invalid ENABLE_CPU_MONITORING value '$ENABLE_CPU_MONITORING', using default value true"
        ENABLE_CPU_MONITORING=true
    fi
    
    if [[ -n "$ENABLE_MEMORY_MONITORING" && ! "$ENABLE_MEMORY_MONITORING" =~ ^(true|false)$ ]]; then
        log_message "WARNING: Invalid ENABLE_MEMORY_MONITORING value '$ENABLE_MEMORY_MONITORING', using default value true"
        ENABLE_MEMORY_MONITORING=true
    fi
    
    if [[ -n "$ENABLE_NETWORK_MONITORING" && ! "$ENABLE_NETWORK_MONITORING" =~ ^(true|false)$ ]]; then
        log_message "WARNING: Invalid ENABLE_NETWORK_MONITORING value '$ENABLE_NETWORK_MONITORING', using default value true"
        ENABLE_NETWORK_MONITORING=true
    fi
    
    # Validate OUTPUT_FORMAT
    if [[ -n "$OUTPUT_FORMAT" && ! "$OUTPUT_FORMAT" =~ ^(text|json)$ ]]; then
        log_message "WARNING: Invalid OUTPUT_FORMAT value '$OUTPUT_FORMAT', using default value text"
        OUTPUT_FORMAT=text
    fi
    
    # Validate DAEMON_MODE
    if [[ -n "$DAEMON_MODE" && ! "$DAEMON_MODE" =~ ^(true|false)$ ]]; then
        log_message "WARNING: Invalid DAEMON_MODE value '$DAEMON_MODE', using default value false"
        DAEMON_MODE=false
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
ENABLE_HISTORICAL_DATA="${ENABLE_HISTORICAL_DATA:-true}"
LOG_ROTATION_SIZE="${LOG_ROTATION_SIZE:-10485760}"  # 10MB default

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

# Function to store historical data for trend analysis
store_historical_data() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local data_file="$PROJECT_DIR/logs/sysmon_data.csv"
    
    # Create CSV header if file doesn't exist
    if [[ ! -f "$data_file" ]]; then
        echo "timestamp,cpu_usage,cpu_load_1m,cpu_load_5m,cpu_load_15m,memory_usage,memory_total,memory_used,swap_usage,network_interfaces" >> "$data_file"
    fi
    
    # Get current metrics
    local cpu_usage=$(get_cpu_usage)
    local cpu_load=$(get_cpu_load)
    local cpu_load_1m=$(echo "$cpu_load" | awk '{print $1}')
    local cpu_load_5m=$(echo "$cpu_load" | awk '{print $2}')
    local cpu_load_15m=$(echo "$cpu_load" | awk '{print $3}')
    
    local memory_info=$(get_memory_info)
    local memory_used=$(echo "$memory_info" | awk '{print $1}' | sed 's/Gi//')
    local memory_total=$(echo "$memory_info" | awk '{print $3}' | sed 's/Gi//')
    local memory_usage=$(get_memory_usage | sed 's/%//')
    
    local swap_usage=$(get_swap_usage | sed 's/%//')
    local network_interfaces=$(get_active_interfaces)
    
    # Append data to CSV file
    echo "$timestamp,$cpu_usage,$cpu_load_1m,$cpu_load_5m,$cpu_load_15m,$memory_usage,$memory_total,$memory_used,$swap_usage,$network_interfaces" >> "$data_file"
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
        
        # Store historical data for trend analysis (if enabled)
        if [[ "$ENABLE_HISTORICAL_DATA" == "true" ]]; then
            store_historical_data
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
    
    # Store historical data for trend analysis (if enabled)
    if [[ "$ENABLE_HISTORICAL_DATA" == "true" ]]; then
        store_historical_data
    fi
    
    log_message "BashWatch system monitor completed"
fi
# BashWatch

[![Build Status](https://img.shields.io/github/workflow/status/<username>/BashWatch/CI?style=flat-square)](https://github.com/<username>/BashWatch/actions)
[![License](https://img.shields.io/github/license/<username>/BashWatch?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/<username>/BashWatch?style=flat-square)](https://github.com/<username>/BashWatch/releases)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS-lightgrey?style=flat-square)](https://github.com/<username>/BashWatch)

A lightweight, modular system monitoring tool written in Bash. Monitor CPU, memory, and network resources with minimal overhead and maximum flexibility.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Examples](#examples)
- [Tech Stack](#tech-stack)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)

## Features

- **Resource Monitoring**: Track CPU usage, memory consumption, and network statistics
- **Continuous Monitoring**: Daemon mode for ongoing system surveillance
- **Alerting System**: Threshold-based notifications for CPU and memory usage
- **Multiple Output Formats**: Switch between human-readable text and JSON output
- **Configurable Thresholds**: Set custom alert levels for each resource type
- **Modular Architecture**: Independent modules for CPU, memory, and network monitoring
- **Command-Line Interface**: Intuitive CLI with comprehensive help system
- **Flexible Configuration**: External configuration file for easy customization
- **Comprehensive Logging**: Timestamped logs with automatic directory creation
- **Container Support**: Ready for Docker deployment
- **Automated Testing**: Complete test suite with CI/CD integration

## Installation

### Prerequisites

- Bash 4.0 or higher
- Standard Unix utilities (`top`, `free`, `cat`, `grep`)
- Optional: `ifstat` for enhanced network monitoring

### Steps

```bash
# Clone the repository
git clone https://github.com/<username>/BashWatch.git

cd BashWatch

# Make scripts executable
chmod +x bin/*.sh lib/*.sh tests/*.sh

# Verify installation
./bin/sysmon.sh --help
```

## Usage

```bash
# Run basic system monitoring
./bin/sysmon.sh

# Show help
./bin/sysmon.sh --help

# Output in JSON format
./bin/sysmon.sh --json

# Run in continuous monitoring mode (daemon)
./bin/sysmon.sh --daemon

# Monitor specific component
./bin/sysmon.sh --cpu
./bin/sysmon.sh --memory
./bin/sysmon.sh --network

# Use custom configuration
./bin/sysmon.sh --config /path/to/custom.conf
```

## Configuration

The configuration file is located at `config/sysmon.conf`. You can customize:

| Setting | Description | Default Value |
|---------|-------------|---------------|
| `LOG_FILE` | Path to log file | `../logs/sysmon.log` |
| `CPU_INTERVAL` | CPU monitoring interval (seconds) | `5` |
| `MEMORY_INTERVAL` | Memory monitoring interval (seconds) | `5` |
| `NETWORK_INTERVAL` | Network monitoring interval (seconds) | `10` |
| `CPU_THRESHOLD` | CPU alert threshold (%) | `80` |
| `MEMORY_THRESHOLD` | Memory alert threshold (%) | `85` |
| `OUTPUT_FORMAT` | Output format (text/json) | `text` |
| `ENABLE_CPU_MONITORING` | Enable CPU monitoring | `true` |
| `ENABLE_MEMORY_MONITORING` | Enable memory monitoring | `true` |
| `ENABLE_NETWORK_MONITORING` | Enable network monitoring | `true` |

## Examples

### Basic Monitoring Output

```
CPU Usage: 15.2%
CPU Load: 1.25 1.45 1.60
CPU Info: Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz

Memory Usage: 45.32%
Memory Info: 8.2GB / 18GB
Swap Usage: 2.15%

Active Interfaces: eth0
Network Stats:
eth0: 12456789 bytes received, 9876543 bytes transmitted
```

### JSON Output

```json
{
  "cpu_usage": "15.2%",
  "cpu_load": "1.25 1.45 1.60",
  "cpu_info": "Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz",
  "memory_usage": "45.32%",
  "memory_info": "8.2GB / 18GB",
  "swap_usage": "2.15%",
  "active_interfaces": "eth0",
  "network_stats": "eth0: 12456789 bytes received, 9876543 bytes transmitted"
}
```

## Tech Stack

- **Language**: Bash (POSIX-compliant)
- **Dependencies**: Standard Unix utilities (`top`, `free`, `vmstat`, `ifstat`, `ip`, `ifconfig`)
- **Containerization**: Docker with Alpine Linux
- **CI/CD**: GitHub Actions
- **Testing**: Custom Bash test framework
- **Documentation**: Markdown

## Testing

```bash
# Run the complete test suite
./tests/run_tests.sh

# Run individual module tests
./tests/test_cpu.sh
./tests/test_memory.sh
./tests/test_network.sh
```

The test suite validates:
- CPU monitoring functions
- Memory tracking accuracy
- Network interface detection
- Configuration loading
- Error handling
- Output formatting

## Deployment

### Docker

```bash
# Build the Docker image
docker build -t bashwatch .

# Run in container
docker run --rm bashwatch

# Run with specific options
docker run --rm bashwatch ./bin/sysmon.sh --json
```

### System-wide Installation

```bash
# Copy to system path
sudo cp bin/sysmon.sh /usr/local/bin/sysmon
sudo chmod +x /usr/local/bin/sysmon

# Run from anywhere
sysmon --help
```

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

```bash
# Install development dependencies
# (Most dependencies are standard Unix tools)

# Run tests before submitting
./tests/run_tests.sh
```

### Coding Standards

- Follow POSIX-compliant Bash scripting
- Use 4-space indentation
- Add comments for complex logic
- Write tests for new functionality
- Update documentation as needed

## Roadmap

- [x] Continuous monitoring mode (daemon)
- [x] Alerting/notification system
- [ ] Historical data storage and trend analysis
- [ ] Web dashboard for visualization
- [ ] Plugin architecture for custom monitors
- [ ] Performance benchmarking
- [ ] Enhanced security features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors who have helped shape BashWatch
- Inspired by the need for lightweight system monitoring solutions
- Built with the power of Bash and standard Unix tools# BashWatch

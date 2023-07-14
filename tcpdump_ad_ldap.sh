#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to display colored messages
print_message() {
    local message=$1
    local color=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command is available
check_command() {
    local command=$1
    if ! command -v $command &> /dev/null; then
        return 1
    fi
}

# Function to install wireshark
install_wireshark() {
    if check_command apt-get; then
        apt-get update
        apt-get install -y wireshark
    elif check_command yum; then
        yum install -y wireshark
    elif check_command dnf; then
        dnf install -y wireshark
    else
        print_message "Unable to install wireshark. Please install it manually." "$YELLOW"
        return 1
    fi
}

# Function to check if tcpdump is installed
check_tcpdump() {
    if ! command -v tcpdump &> /dev/null; then
        print_message "tcpdump is not installed. Please install tcpdump and try again." "$RED"
        exit 1
    fi
}

# Function to capture network traffic
capture_traffic() {
    local container_id=$1
    local interface=$2
    local output_file="/tmp/output_$(date +%Y%m%d%H%M%S).pcap"
    local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_id)
    local tcpdump_command="tcpdump -i $interface -w $output_file -n host $container_ip and port 636"

    # Start tcpdump in the background
    $tcpdump_command &
    local pid=$!

    print_message "Capturing network traffic from container $container_id (IP: $container_ip) on interface $interface..." "$GREEN"
    print_message "Press Ctrl+C to stop the capture." "$GREEN"

    # Wait for user to terminate the script
    trap 'kill $pid' SIGINT
    wait

    print_message "Network traffic capture completed. Output file: $output_file" "$GREEN"

    # Check if tshark is installed
    if check_command tshark; then
        tshark -r $output_file
    else
        print_message "tshark is not installed. Please install wireshark to get tshark." "$YELLOW"
    fi
}

# Main script logic
check_tcpdump

# Find the container ID
container_id=$(docker ps -qf name=ad-ldap_default)

# Check if the container is running
if [[ -z "$container_id" ]]; then
    print_message "Container 'ad-ldap_default' is not running." "$RED"
    exit 1
fi

# Install Wireshark if not already installed
if ! check_command wireshark; then
    print_message "Wireshark is not installed. Installing..." "$YELLOW"
    install_wireshark
fi

# Capture network traffic
capture_traffic "$container_id" "ad-default"

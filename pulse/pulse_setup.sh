#!/bin/bash
# Un-official script, Acceldata Inc.
# Define text colors for output
YELLOW=$'\033[0;33m'
GREEN=$'\e[0;32m'
BLUE=$'\033[0;94m'
RED=$'\e[0;31m'
GREY=$'\033[90m'
ICyan=$'\033[0;96m'
CYAN=$'\033[0;36m'
NC=$'\e[0m'
TICK="✅"
CROSS="❌" # Cross symbol for indicating failed steps

print_success1() {
  echo -e "${BLUE}${TICK} Success: $1${NC}"
}

print_success() {
  echo -e "${GREEN}${TICK} Success: $1${NC}"
}

# Function to print error messages with red color
print_error() {
  echo -e "${RED}${CROSS} Error: $1${NC}"
}

# Function to print a message with a separator
print_message() {
  separator="${GREY}*********************************************************************${NC}"
  echo -e "${separator}"
  echo "$1"
  echo -e "${separator}"
}

# Display usage information
show_usage() {
  cat <<EOM
    ${ICyan}
   __    ___  ___  ____  __    ____    __   ____   __
  /__\  / __)/ __)( ___)(  )  (  _ \  /__\ (_  _) /__\
 /(__)\( (__( (__  )__)  )(__  )(_) )/(__)\  )(  /(__)\
(__)(__)\___)\___)(____)(____)(____/(__)(__)(__)(__)(__)
    ${NC}
  ${CYAN}/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${NC}
${YELLOW}Usage: $(basename $0) [check_os_prerequisites, check_docker_prerequisites, install_pulse, configure_ssl_for_pulse]${NC}
Parameters:
  - ${BLUE}check_os_prerequisites${NC}: Verify Umask, SELinux, and sysctl settings.
  - ${BLUE}check_docker_prerequisites${NC}: Check and install Docker with required settings.
  - ${BLUE}install_pulse${NC}: Install Acceldata Pulse following specific steps.
  - ${BLUE}full_install_pulse${NC}: Include OS and Docker Pre-req setup and along with Pulse initial setup.
  - ${BLUE}configure_ssl_for_pulse${NC}: If SSL is enabled on Hadoop Cluster, Pass cacerts file to Pulse config.
Examples:
  ./$(basename $0) ${GREEN}check_os_prerequisites${NC}
  ./$(basename $0) ${GREEN}check_docker_prerequisites${NC}
  ./$(basename $0) ${GREEN}install_pulse${NC}
  ./$(basename $0) ${GREEN}full_install_pulse${NC}
  ./$(basename $0) ${GREEN}configure_ssl_for_pulse${NC}
EOM
  exit 0
}

# Check if a command-line argument is provided
[ -z $1 ] && { show_usage; }

check_os_prerequisites () {
  specs | sed -e "s/\(.*\)/${YELLOW}\1${NC}/"
  check_umask
  check_selinux
  configure_sysctl_settings
}

check_docker_prerequisites () {
  install_docker
  configure_docker_daemon_settings
}

full_install_pulse () {
  check_os_prerequisites
  check_docker_prerequisites
  install_pulse
}

# Detect the operating system
os=""

if grep -qi "ubuntu" /etc/os-release; then
  os="Ubuntu"
elif grep -qiE "rhel|centos" /etc/os-release; then
  os="CentOS"
fi

# Check if the detected OS is supported, and exit if it's not
if [ -z "$os" ]; then
  echo -e "${RED}${CROSS} OS not supported${NC}"
  exit 94
fi

# Function to display system information
specs() {
  # OS information
  os_version=$(awk -F'=' '/VERSION_ID/ {gsub(/"/, "", $2); print $2}' /etc/os-release)
  echo -e "${GREY}*********************************************************************${NC}"
  echo -e "${ICyan}OS: $os $os_version${NC}"

  # Number of CPU cores
  cpu_cores=$(nproc)
  echo -e "${GREY}*********************************************************************${NC}"
  echo -e "${ICyan}Number of CPU cores: $cpu_cores${NC}"

  # Memory information
  echo -e "${GREY}*********************************************************************${NC}"
  echo -e "${ICyan}Memory Information:${NC}"
  free -h

  # Storage information (excluding Docker and tmpfs filesystems)
  echo -e "${GREY}*********************************************************************${NC}"
  echo -e "${ICyan}Storage Information:${NC}"
  df -hP | grep -vE 'docker|tmpfs'

  # Additional system details can be added here
}


# Function to check and set umask
check_umask() {
  print_message "Checking Umask..."
  grep 022 /etc/profile 2>/dev/null >/dev/null
  if [ $? -eq 0 ]; then
      print_success1 "Umask is correctly set (022)."
  else
      echo "Umask not set. Setting umask to 0022."
      echo "umask 0022" >> /etc/profile 2>/dev/null >/dev/null
      print_success "Umask set to 0022."
  fi
}

# Function to check and disable SELinux
check_selinux() {
  print_message "Checking SELinux..."
  sestatus | grep "SELinux status" | grep enabled 2>/dev/null >/dev/null
  if [ $? -eq 0 ]; then
      setenforce 0
      sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config 2>/dev/null >/dev/null
      print_success "SELinux disabled."
  else
      print_success1 "SELinux is already disabled."
  fi
}

# Function to configure sysctl settings
configure_sysctl_settings() {
  print_message "Checking Sysctl Settings for vm.max_map_count and Port Forwarding..."
  if grep -q "vm.max_map_count=262144" /etc/sysctl.conf && grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
      print_success1 "Sysctl settings are already present in /etc/sysctl.conf"
  else
      echo "Enabling Port Forwarding and Sysctl Settings..."
      grep "vm.max_map_count=262144" /etc/sysctl.conf >/dev/null || sh -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.conf" 2>/dev/null >/dev/null
      grep "net.ipv4.ip_forward=1" /etc/sysctl.conf >/dev/null || sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf" 2>/dev/null >/dev/null
      sudo sysctl -p /etc/sysctl.conf 2>/dev/null >/dev/null
      print_success "Sysctl settings configured."
  fi
}

# Function to check and install Docker with a minimum required version
install_docker() {
  print_message "Checking Docker..."
  if ! command -v docker &> /dev/null; then
      echo "Docker is not installed."
      echo "To install Docker, you can run the following commands:"
      echo "1. sudo yum install -y yum-utils"
      echo "2. sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
      echo "3. sudo yum -y install docker-ce docker-ce-cli containerd.io"
      read -p "Do you want to install Docker? (yes/no): " choice
      if [ "$choice" == "yes" ]; then
          echo "Installing Docker..."
          sudo yum install -y yum-utils
          sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
          sudo yum -y install docker-ce docker-ce-cli containerd.io
      else
          print_error "Please install Docker manually and re-run the script."
          exit 1
      fi
  fi

  # Check the Docker version and ensure it's greater than or equal to 20.10.x
  docker_version=$(docker -v | awk -F'[ ,]+' '{print $3}' | cut -c 1-4)
  if (( $(echo "$docker_version >= 20.10" | bc -l) )); then
      print_success "Docker Version $docker_version is Installed"
  else
      print_error "Docker is installed, but the version ($docker_version) is not compatible. Please install Docker version 20.10.x or above manually and re-run the script."
      exit 1
  fi
}


# Function to configure Docker daemon settings
configure_docker_daemon_settings() {
  print_message "Configuring Docker Daemon Settings..."
  if [ -f /etc/docker/daemon.json ]; then
      mv /etc/docker/daemon.json /etc/docker/daemon.json_bk &>/dev/null
  fi
  touch /etc/docker/daemon.json &>/dev/null

  echo "{
    \"live-restore\": true,
    \"log-driver\": \"json-file\",
    \"log-opts\": {
      \"mode\": \"non-blocking\",
      \"max-buffer-size\": \"4m\",
      \"max-size\": \"10m\",
      \"max-file\": \"3\"
    }
  }" > /etc/docker/daemon.json

  systemctl daemon-reload
  systemctl enable docker >/dev/null
  systemctl restart docker && print_success "Docker daemon configured."
}

install_pulse() {
  print_message "Installing Pulse"
  separator="************************************************"
  echo -e "${separator}"
  echo -e "\e[1;34mPlease follow these steps to install Pulse:\e[0m"
  echo ""
  echo -e "\e[1;34m1. Make sure you have set up the AcceloHome Data directory path (e.g., /data01/acceldata).\e[0m"
  echo -e "\e[1;34m2. Download and copy the 'accelo.linux' file to the AcceloHome Data directory path as '/data01/acceldata/accelo'.\e[0m"
  echo -e "\e[1;34m3. Copy the Pulse license file into '/data01/acceldata/work/license'. Please create the 'work' directory before copying the file.\e[0m"
  echo -e "\e[1;34m3. If Kerberos is enabled in Cluster, Please get hdfs keytab, krb5.conf file on Pulse server\e[0m"
  echo -e "\e[1;34m3. Please get Database credentials handy for Hive and Oozie database\e[0m"
  echo -e "\e[1;34m4. Make sure to load Pulse tar images into Docker using the provided command:\e[0m"
  echo -e "\e[1;32m   'ls -1 *.tgz | xargs --no-run-if-empty -L 1 docker load -i'\e[0m"
  echo ""

  read -p "Do you want to proceed with these steps? (yes/no): " choice
  if [ "$choice" == "yes" ]; then
      read -p "Enter the AcceloHome Data dir path: " AcceloHome
      if [ -d "$AcceloHome" ]; then
          chmod +x $AcceloHome/accelo
          cd $AcceloHome
          ./accelo init
          sleep 2
          source /etc/profile.d/ad.sh
          ./accelo init
          cd
          which accelo && print_success "Run -> accelo config cluster "
      else
          print_error "AcceloHome directory doesn't exist. Please create it and re-run the script."
          exit 1
      fi
  else
      echo "Pulse installation canceled."
  fi
}

function configure_ssl_for_pulse {
# Ask if this is a Pulse Core Server
echo -e "${CYAN}Is this a Pulse Core Server? (yes/no):${NC}\c"
read is_pulse_core
case "$is_pulse_core" in
[Yy][Ee][Ss] | [Yy])
  is_pulse_core="yes"
  ;;
[Nn][Oo] | [Nn])
  is_pulse_core="no"
  ;;
*)
  echo "Invalid input. Please enter 'yes' or 'no'."
  exit 1
  ;;
esac

  if [[ "$is_pulse_core" == "yes" || "$is_pulse_core" == "y" ]]; then
  # Load the ad.sh profile
  source /etc/profile.d/ad.sh
  # Check if the AcceloHome variable is set
  if [[ -z "$AcceloHome" ]]; then
    echo -e "${RED}Error: AcceloHome variable is not set. Please set it before running the script.${NC}"
    exit 1
  fi

  # Ask for the path to the cacerts file
  read -e -p "Enter the complete path of the cacerts file: " cacerts_path

  # Check if the cacerts file is present
  if [ ! -f "$cacerts_path" ]; then
    echo "Error: The cacerts file does not exist at $cacerts_path. Please ensure that the cacerts file is present before running the script."
    exit 1
  fi

  # Copy the cacerts file to $AcceloHome/config/security/
  cp "$cacerts_path" "$AcceloHome/config/security/"
  cp "$cacerts_path" "$AcceloHome/config/security/jssecacerts"

  # Update permissions on all files in $AcceloHome/config/security/
  chmod 0655 $AcceloHome/config/security/*

  # Check for the ad-core-connectors.yml file
  if [ ! -f "$AcceloHome/config/docker/addons/ad-core-connectors.yml" ]; then
    accelo admin makeconfig ad-core-connectors || {
      echo "Error: Failed to create ad-core-connectors.yml"
      exit 1
    }
  fi

  # Check for the ad-core.yml file
  if [ ! -f "$AcceloHome/config/docker/ad-core.yml" ]; then
    accelo admin makeconfig ad-core || {
      echo "Error: Failed to create ad-core.yml"
      exit 1
    }
  fi

  # Check for the ad-fsanalyticsv2-connector.yml file
  if [ ! -f "$AcceloHome/config/docker/addons/ad-fsanalyticsv2-connector.yml" ]; then
    accelo admin makeconfig ad-fsanalyticsv2-connector || {
      echo "Error: Failed to create ad-fsanalyticsv2-connector.yml"
      exit 1
    }
  fi

  if [ ! -f "$AcceloHome/config/security/cacerts" ]; then
    echo -e "${RED}Error: The cacerts file does not exist at $AcceloHome/config/security/cacerts. Please ensure that the cacerts file is present before running the script.${NC}"
    exit 1
  fi

  # Check the current volumes section in ad-core.yml
  volumes_section=$(awk '/ad-streaming:/,/ulimits:/' "$AcceloHome/config/docker/ad-core.yml")

  # Check if the cacerts file is already in the volumes section
  if echo "$volumes_section" | grep -q "$AcceloHome/config/security/cacerts"; then
    echo -e "${GREEN}The cacerts file is already in the volumes section of ad-core.yml${NC}"
  else
    # Add the cacerts file to the volumes section
    sed -i "/ad-streaming:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/cacerts:/usr/local/openjdk-8/lib/security/cacerts|" "$AcceloHome/config/docker/ad-core.yml"
    sed -i "/ad-streaming:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/jssecacerts:/usr/local/openjdk-8/lib/security/jssecacerts|" "$AcceloHome/config/docker/ad-core.yml"
    echo -e "${GREEN} Successfully added the cacerts file to the volumes section of ad-core.yml${NC}"
  fi

  # Check the current volumes section in ad-core-connectors.yml
  ad_core_volumes_section=$(awk '/ad-connectors:/,/ulimits:/' "$AcceloHome/config/docker/addons/ad-core-connectors.yml")

  # Check if the cacerts file is already in the volumes section
  if echo "$ad_core_volumes_section" | grep -q "$AcceloHome/config/security/cacerts"; then
    echo -e "${GREEN}The cacerts file is already in the volumes section of ad-core-connectors.yml${NC}"
  else
    # Add the cacerts file to the volumes section
    sed -i "/ad-connectors:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/cacerts:/usr/local/openjdk-8/lib/security/cacerts|" "$AcceloHome/config/docker/addons/ad-core-connectors.yml"
    sed -i "/ad-connectors:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/jssecacerts:/usr/local/openjdk-8/lib/security/jssecacerts|" "$AcceloHome/config/docker/addons/ad-core-connectors.yml"
    echo -e "${GREEN}Successfully added the cacerts file to the volumes section of ad-core-connectors.yml${NC}"
  fi

  ad_sparkstats_volumes_section=$(awk '/ad-sparkstats:/,/ulimits:/' "$AcceloHome/config/docker/addons/ad-core-connectors.yml")

  # Check if the cacerts file is already in the volumes section
  if echo "$ad_sparkstats_volumes_section" | grep -q "$AcceloHome/config/security/cacerts"; then
    echo -e "${GREEN}The cacerts file is already in the volumes section of ad-core-connectors.yml${NC}"
  else
    # Add the cacerts file to the volumes section
    sed -i "/ad-sparkstats:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/cacerts:/usr/local/openjdk-8/lib/security/cacerts|" "$AcceloHome/config/docker/addons/ad-core-connectors.yml"
    sed -i "/ad-sparkstats:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/jssecacerts:/usr/local/openjdk-8/lib/security/jssecacerts|" "$AcceloHome/config/docker/addons/ad-core-connectors.yml"
    echo -e "${GREEN}Successfully added the cacerts file to the volumes section of ad-core-connectors.yml${NC}"
  fi

  ad_fs_volumes_section=$(awk '/ad-fsanalyticsv2-connector:/,/ulimits:/' "$AcceloHome/config/docker/addons/ad-fsanalyticsv2-connector.yml")

  # Check if the cacerts file is already in the volumes section
  if echo "$ad_fs_volumes_section" | grep -q "$AcceloHome/config/security/cacerts"; then
    echo -e "${GREEN}The cacerts file is already in the volumes section of ad-core-connectors.yml${NC}"
  else
    # Add the cacerts file to the volumes section
    sed -i "/ad-fsanalyticsv2-connector:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/cacerts:/usr/local/openjdk-8/lib/security/cacerts|" "$AcceloHome/config/docker/addons/ad-fsanalyticsv2-connector.yml"
    sed -i "/ad-fsanalyticsv2-connector:/,/ulimits:/ s|volumes:|volumes:\n    - $AcceloHome/config/security/jssecacerts:/usr/local/openjdk-8/lib/security/jssecacerts|" "$AcceloHome/config/docker/addons/ad-fsanalyticsv2-connector.yml"

    echo -e "${GREEN}Successfully added the cacerts file to the volumes section of ad-fsanalyticsv2-connector.yml${NC}"
  fi

  fi

}

# Main script logic
case "$1" in
  check_os_prerequisites)
    check_os_prerequisites
    ;;
  check_docker_prerequisites)
    check_docker_prerequisites
    ;;
  install_pulse)
    install_pulse
    ;;
  full_install_pulse)
    full_install_pulse
    ;;
  configure_ssl_for_pulse)
    configure_ssl_for_pulse
    ;;
  *)
    show_usage
    ;;
esac

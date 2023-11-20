#!/bin/bash
# Un-official script, Acceldata Inc.

YELLOW=$'\033[0;33m'
GREEN=$'\e[0;32m'
BLUE=$'\033[0;94m'
DARK_BLUE=$'\033[0;34m'
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

logStep() {
    printf "${BLUE}${TICK} $1${NC}\n" 1>&2
}

logSuccess() {
    printf "${GREEN}${TICK} $1${NC}\n" 1>&2
}

logFailure() {
    printf "${RED}${CROSS} $1${NC}\n" 1>&2
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
    ${DARK_BLUE}
 █████╗  ██████╗ ██████╗███████╗██╗     ██████╗  █████╗ ████████╗ █████╗         ██████╗ ██╗   ██╗██╗     ███████╗███████╗
██╔══██╗██╔════╝██╔════╝██╔════╝██║     ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗        ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
███████║██║     ██║     █████╗  ██║     ██║  ██║███████║   ██║   ███████║        ██████╔╝██║   ██║██║     ███████╗█████╗
██╔══██║██║     ██║     ██╔══╝  ██║     ██║  ██║██╔══██║   ██║   ██╔══██║        ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝
██║  ██║╚██████╗╚██████╗███████╗███████╗██████╔╝██║  ██║   ██║   ██║  ██║        ██║     ╚██████╔╝███████╗███████║███████╗
╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝        ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝
    ${NC}
  ${CYAN}/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${NC}
${YELLOW}Usage: $(basename $0) [check_os_prerequisites, check_docker_prerequisites, install_pulse, configure_ssl_for_pulse, enable_gauntlet, configure_pulse_multinode_mongo_uri ]${NC}
Parameters:
  - ${BLUE}check_os_prerequisites${NC}: Verify Umask, SELinux, and sysctl settings.
  - ${BLUE}check_docker_prerequisites${NC}: Check and install Docker with required settings.
  - ${BLUE}install_pulse${NC}: Install Acceldata Pulse following specific steps.
  - ${BLUE}full_install_pulse${NC}: Include OS and Docker Pre-req setup and along with Pulse initial setup.
  - ${BLUE}configure_ssl_for_pulse${NC}: If SSL is enabled on Hadoop Cluster, Pass cacerts file to Pulse config.
  - ${BLUE}enable_gauntlet${NC}: This component is used to delete elastic indices and run purge/compact operations on the Mongo DB collections.
  - ${BLUE}set_daily_cron_gauntlet${NC}: Change CRON_TAB_DURATION for ad-gauntlet to next 5 min or default value.  
  - ${BLUE}configure_pulse_multinode_mongo_uri${NC}: Pulse Multi-Node Setup to update MONGO_URI in ad.sh file.
Examples:
  ./$(basename $0) ${GREEN}check_os_prerequisites${NC}
  ./$(basename $0) ${GREEN}check_docker_prerequisites${NC}
  ./$(basename $0) ${GREEN}install_pulse${NC}
  ./$(basename $0) ${GREEN}full_install_pulse${NC}
  ./$(basename $0) ${GREEN}configure_ssl_for_pulse${NC}
  ./$(basename $0) ${GREEN}enable_gauntlet${NC}
  ./$(basename $0) ${GREEN}set_daily_cron_gauntlet${NC}  
  ./$(basename $0) ${GREEN}configure_pulse_multinode_mongo_uri${NC}  
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

  # Define the required configuration
  required_config="{
    \"live-restore\": true,
    \"log-driver\": \"json-file\",
    \"log-opts\": {
      \"mode\": \"non-blocking\",
      \"max-buffer-size\": \"4m\",
      \"max-size\": \"10m\",
      \"max-file\": \"3\"
    }
  }"

  # Check if /etc/docker/daemon.json exists
  if [ -f /etc/docker/daemon.json ]; then
      # Check if the required configuration already exists in daemon.json
      if ! grep -qF "$required_config" /etc/docker/daemon.json; then
          # Append the required configuration
          mv /etc/docker/daemon.json /etc/docker/daemon.json_bk &>/dev/null
          echo "$required_config" > /etc/docker/daemon.json
          print_success "Docker daemon settings updated."
          # Reload Docker daemon
          systemctl daemon-reload
          # Enable and restart Docker
          systemctl enable docker >/dev/null
          systemctl restart docker && print_success "Docker daemon configured."
      else
          # The required configuration is already present
          print_success1 "Docker daemon is already configured."
      fi
  else
      # Create /etc/docker/daemon.json if it doesn't exist
      echo "$required_config" > /etc/docker/daemon.json
      print_success "Docker daemon settings updated."
  fi
}

install_pulse() {
    print_message "Installing Pulse..."
    echo -e "${YELLOW}Please follow these steps to install Pulse:\e[0m"
    echo ""
    echo -e "\e[1;34m1. Make sure you have set up the AcceloHome Data directory path (e.g., /data01/acceldata).\e[0m"
    echo -e "\e[1;34m2. Download and copy the 'accelo.linux' file to the AcceloHome Data directory path as '/data01/acceldata/accelo'.\e[0m"
    echo -e "\e[1;34m3. Copy the Pulse license file into '/data01/acceldata/work/license'. Please create the 'work' directory before copying the file.\e[0m"
    echo -e "\e[1;34m3. If Kerberos is enabled in Cluster, Please get hdfs keytab, krb5.conf file on Pulse server\e[0m"
    echo -e "\e[1;34m3. Please get Database credentials handy for Hive and Oozie database\e[0m"
    echo -e "\e[1;34m4. Make sure to load Pulse tar images into Docker using the provided command:\e[0m"
    echo -e "${YELLOW}   'ls -1 *.tgz | xargs --no-run-if-empty -L 1 docker load -i'\e[0m"
    echo ""

    read -p "Do you want to proceed with these steps? ${YELLOW}(yes/no)${NC}: " choice

    if [ "$choice" == "yes" ]; then
        read -p "Enter the AcceloHome Data dir path: " AcceloHome

        if [ ! -d "$AcceloHome" ]; then
            read -p "${CYAN}Looks like the folder does not exist. Do you want to proceed and create this folder? [y/n]: ${NC}" ANS

            if [[ "$ANS" == "y" || "$ANS" == "yes" ]]; then
                mkdir -p "$AcceloHome"
            elif [[ "$ANS" == "n" || "$ANS" == "no" ]]; then
                echo "${CYAN}User chose not to create the folder. Exiting script.${NC}" && exit 86
            else
                echo "${RED}Invalid answer. Exiting script.${NC}" && exit 87
            fi
        fi

        if [ -z "$(ls -A "${AcceloHome}" | grep -v -E 'work|accelo|accelo.linux')" ]; then
            echo "${YELLOW}Directory is empty.${NC}"
        else
            echo "${YELLOW}Directory is not empty.${NC}" && exit 88
        fi

        if [ ! -f "${AcceloHome}/work/license" ]; then
            # Check if the license file exists, if not, ask the user to provide it
            read -e -p "Provide Pulse license file [path/to/license], if not exist, create it and provide the complete path of the file: " lipath

            if [ ! -f "$lipath" ]; then
                echo "${YELLOW}License file is not present at the specified path.${NC}" && exit 89
            fi

            mkdir -p "${AcceloHome}/work"
            cp "$lipath" "${AcceloHome}/work/license"
        fi

        if [ -d "$AcceloHome" ]; then
            if [ -z "$(ls -A "${AcceloHome}/accelo")" ]; then
                echo "${YELLOW}Accelo binary file does not exist.${NC}"

                read -p "Do you have the 'accelo.linux' binary file? ${YELLOW}(yes/no)${NC}: " haveAcceloBinary

                if [ "$haveAcceloBinary" == "yes" ]; then
                    read -e -p "Provide the complete path to the 'accelo.linux' binary file or the directory containing it: " acceloBinaryPath

                    if [ -f "$acceloBinaryPath" ]; then
                        cp "$acceloBinaryPath" "${AcceloHome}/accelo"
                        chmod +x "${AcceloHome}/accelo"
                        echo "${CYAN}Accelo binary file copied successfully.${NC}"
                    else
                        echo "${RED}Invalid file path. Exiting script.${NC}" && exit 100
                    fi
                else
                    echo "${CYAN}Copy 'accelo.linux' binary file to '${AcceloHome}/accelo' or provide the complete path.${NC}"
                    exit 88
                fi
            fi

            echo "${YELLOW}Accelo binary file exists.${NC}"

            read -p "Have you loaded Pulse Docker images? ${YELLOW}(yes/no)${NC}: " loadedPulseImages

            if [ "$loadedPulseImages" == "yes" ]; then
                chmod +x "$AcceloHome/accelo"
                cd "$AcceloHome"
                ./accelo init
                sleep 2
                source "/etc/profile.d/ad.sh"
                ./accelo init

                if [ $? -eq 0 ]; then
                    echo "${CYAN}Accelo init completed successfully${NC}"
                fi

                accelo info
                cd
                which accelo && echo "${GREEN}Run -> accelo config cluster${NC}"
                echo -e "${CYAN}For more information, visit: https://docs.acceldata.io/pulse/documentation/single-node-installation-guide#configure-the-acceldata-core-components${NC}"
            else
                # Continue with the rest of the installation steps
                read -e -p "Do you already have the pulse tarball file ${CYAN}(yes/y/no/n): ${NC}" pulsetar

                if [[ "$pulsetar" == "yes" || "$pulsetar" == "y" ]]; then
                    read -e -p "Location of the pulse tarball file ${CYAN}[path/to/folder]: ${NC}" pulpath
                    read -e -p "${RED}Version of Pulse given: ${NC}" ver

                    if [ ! -f "$pulpath" ]; then
                        echo "${RED}Folder does not exist. Exiting.${NC}" && exit 100
                    fi

                    mkdir -p "/tmp/pulse-$ver"
                    echo "${CYAN}Extracting Pulse tarball${NC}"
                    tar -xf "$pulpath" -C "/tmp/pulse-$ver"
                    echo "${GREEN}Extraction complete${NC}"
                    cp "/tmp/pulse-$ver/accelo.linux" "${AcceloHome}/accelo"
                    echo "${CYAN}Extracting images for Pulse${NC}"

                    for FILE in "/tmp/pulse-$ver/ad-"*.tgz; do
                        docker load <"$FILE"
                    done 2>/dev/null
                else
                    echo "${RED}AcceloHome directory doesn't exist. Please create it and re-run the script.${NC}" && exit 1
                fi
            fi
        else
            echo "${RED}AcceloHome directory doesn't exist. Please create it and re-run the script.${NC}" && exit 1
        fi
    else
        echo -e "${RED}User chose not to proceed. Exiting script.${NC}"
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
  cp "$cacerts_path" "$AcceloHome/config/security/cacerts"
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


# Function to enable gauntlet
enable_gauntlet() {
  # Source the ad.sh profile
  source /etc/profile.d/ad.sh

  # Check if AcceloHome variable is set
  if [ -z "$AcceloHome" ]; then
    logFailure "Error: AcceloHome variable is not set."
    return 1
  fi

  # Check if accelo.yml exists
  accelo_yml="$AcceloHome/config/accelo.yml"
  if [ ! -f "$accelo_yml" ]; then
    logFailure "Error: $accelo_yml not found."
    return 1
  fi

  # Check if enable_gauntlet is set to false in accelo.yml
  enable_gauntlet=$(grep "enable_gauntlet:" "$accelo_yml" | awk '{print $2}')
  if [ "$enable_gauntlet" == "true" ]; then
    logSuccess "Gauntlet is already enabled."
    return 0
  fi

  read -p "Gauntlet is currently disabled. Do you want to enable it? (y/n): " enable_response
  if [ "$enable_response" == "y" ]; then
    sed -i 's/enable_gauntlet: false/enable_gauntlet: true/' "$accelo_yml"
    logSuccess "Gauntlet is now enabled."
  else
    logStep "Gauntlet remains disabled."
  fi

  # Check if ad-core.yml exists
  ad_core_yml="$AcceloHome/config/docker/ad-core.yml"
  if [ ! -f "$ad_core_yml" ]; then
    logStep "ad-core.yml not found. Generating it..."
    echo "accelo admin makeconfig ad-core"
    accelo admin makeconfig ad-core
  fi

  # Check and update DRY_RUN_ENABLE in ad-core.yml
  dry_run_enable=$(awk '/ad-gauntlet:/,/extra_hosts:/' "$ad_core_yml" | grep "DRY_RUN_ENABLE" | cut -d' ' -f3)
  if [ "$dry_run_enable" == "false" ]; then
    logStep "Setting DRY_RUN_ENABLE to true in ad-core.yml..."
    sed -i 's/DRY_RUN_ENABLE=false/DRY_RUN_ENABLE=true/' "$ad_core_yml"
  fi

  # Execute the commands
  logStep "Executing the following commands:"
  logStep "accelo admin database push-config"
  echo "y" | accelo admin database push-config
  logStep "accelo restart ad-gauntlet"
  echo "y" | accelo restart ad-gauntlet
}

# Function to calculate and set cron expression
set_daily_cron_gauntlet() {
  # Set AcceloHome variable
  source /etc/profile.d/ad.sh

  # Check if ad-core.yml exists
  ad_core_yml="$AcceloHome/config/docker/ad-core.yml"
  if [ ! -f "$ad_core_yml" ]; then
    logFailure "ad-core.yml not found. Generating it..."
    accelo admin makeconfig ad-core
  fi

  # Check if default CRON_TAB_DURATION is already configured
  default_cron_configured=$(grep "CRON_TAB_DURATION=0 0 */2 * *" "$ad_core_yml")

  if [ -n "$default_cron_configured" ]; then
    logSuccess "Default CRON_TAB_DURATION is already configured in ad-core.yml."
    return
  fi

  # Calculate the next 5 minutes
  next_5_minutes=$(date -d '+5 minutes' '+%M %H')

  # Extract minutes and hours
  next_5_minutes_array=($next_5_minutes)
  next_minutes=${next_5_minutes_array[0]}
  next_hours=${next_5_minutes_array[1]}

  # Set the cron expression
  CRON_TAB_DURATION_5="$next_minutes $next_hours * * *"

  # Display the calculated cron expression
  logStep "CRON_TAB_DURATION_5 set to: $CRON_TAB_DURATION_5"

  # Prompt user to change CRON_TAB_DURATION to next 5 minutes
  read -p "Do you want to set CRON_TAB_DURATION to the next 5 minutes? (y/n): " change_cron_response

  if [ "$change_cron_response" == "y" ]; then
    # Get the current value from the file
    current_cron_value=$(grep "CRON_TAB_DURATION=" "$ad_core_yml" | cut -d'=' -f2)

    # Take a backup of ad-core.yml
    backup_file="$AcceloHome/config/docker/ad-core.yml.bak"
    cp "$ad_core_yml" "$backup_file"
    logSuccess "Backup of ad-core.yml created: $backup_file"

    # Update CRON_TAB_DURATION in ad-core.yml
    sed -i "s/CRON_TAB_DURATION=$current_cron_value/CRON_TAB_DURATION=$CRON_TAB_DURATION_5/" "$ad_core_yml"
    logSuccess "CRON_TAB_DURATION updated to next 5 minutes in ad-core.yml."
  else
    # Prompt user to switch back to the default value
    read -p "Do you want to switch back to the default CRON_TAB_DURATION (0 0 */2 * *)? (y/n): " switch_default_response

    if [ "$switch_default_response" == "y" ]; then
      # Get the current value from the file
      current_cron_value=$(grep "CRON_TAB_DURATION=" "$ad_core_yml" | cut -d'=' -f2)

      # Take a backup of ad-core.yml
      backup_file="$AcceloHome/config/docker/ad-core.yml.bak"
      cp "$ad_core_yml" "$backup_file"
      logSuccess "Backup of ad-core.yml created: $backup_file"

      # Update CRON_TAB_DURATION to the default value in ad-core.yml
      sed -i "s/CRON_TAB_DURATION=$current_cron_value/CRON_TAB_DURATION=0 0 */2 * */" "$ad_core_yml"
      logSuccess "CRON_TAB_DURATION switched back to the default value in ad-core.yml."
    else
      logStep "CRON_TAB_DURATION_5 remains set to the calculated value."
    fi
  fi
}

function configure_pulse_multinode_mongo_uri {

    echo -e "${YELLOW}Generate the encrypted string for the MongoDB URI :${NC}"
    read -e -p "Please provide the Pulse Core server Hostname or IP address: " PULSECORE

    STRING="mongodb://accel:ACCELUSER_01082018@$PULSECORE:27017"

    # Run the command and capture the encrypted string
    encrypted_string=$(echo "$STRING" | accelo admin encrypt 2>/dev/null | grep -oP 'ENCRYPTED:\s+\K.*')

    # Check if the variables exist and remove them
    profile_file="/etc/profile.d/ad.sh"
    sed -i '/^export MONGO_URI=/d' "$profile_file"
    sed -i '/^export MONGO_ENCRYPTED=/d' "$profile_file"
    sed -i '/^export PULSE_SA_NODE=/d' "$profile_file"

    # Append the variables to the profile file
    echo "export MONGO_URI=\"$encrypted_string\"" >> "$profile_file"
    echo "export MONGO_ENCRYPTED=true" >> "$profile_file"
    echo "export PULSE_SA_NODE=true" >> "$profile_file"

    source /etc/profile.d/ad.sh

    active_cluster_name=$(accelo info 2>&1 | grep 'Active Cluster Name' | awk '{print $4}')

    if [ "$active_cluster_name" == "NotFound" ]; then
        logFailure "WARNING: Active Cluster Name is set to NotFound. Configuration may not be correct. Please check."
    else
        logSuccess "Active Cluster Name is: $active_cluster_name. Pulse Multi-node Setup is configured successfully."
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
  enable_gauntlet)
    enable_gauntlet
    ;;
  set_daily_cron_gauntlet)
    set_daily_cron_gauntlet
    ;;       
  configure_ssl_for_pulse)
    configure_ssl_for_pulse
    ;;
  configure_pulse_multinode_mongo_uri)
    configure_pulse_multinode_mongo_uri
    ;;    
  *)
    show_usage
    ;;
esac

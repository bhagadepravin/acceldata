#!/bin/bash
# Pravin Bhagade

set -E 
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

# wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/installpulse.sh && chmod +x installpulse.sh && bash installpulse.sh
# curl -sSL https://raw.githubusercontent.com/bhagadepravin/acceldata/main/installpulse.sh | bash

# What does script Do:
# Set JAVA_HOME, umask, selinux, sysctl, firewalld, install and setup docker.

# Pulse Setup : https://docs.acceldata.io/pulse/prerequisites
# Minimum Requirement

# Number of Pulse Nodes : 1
# Pulse Server RAM : 64GB
# Number of Pulse Core Servers : 16
# Pulse Server Storage : 1TB

echo "Check if JAVA_HOME exists or not"
if [ -z "${JAVA_HOME}" ]
then
    JAVA_HOME=$(readlink -nf $(which java) | xargs dirname | xargs dirname | xargs dirname)
    if [ ! -e "$JAVA_HOME" ]
    then
        JAVA_HOME=""
    fi
    export JAVA_HOME=$JAVA_HOME
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bash_profile
fi

grep 022 /etc/profile 2>/dev/null >/dev/null
if [ $? -eq 0 ]; then
   echo "umask 022 exists"
else
   echo "umask 0022" >> /etc/profile
   fi

sestatus  | grep "SELinux status" | grep enabled 2>/dev/null >/dev/null
if [ $? -eq 0 ]; then
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config 2>/dev/null >/dev/null
else
echo "SELinux is disabled already"
fi


# DNS	Require DNS resolution from Pulse server to cluster nodes or from cluster nodes to Pulse server. Test with nslookup command to check forward and reverse lookup of hosts.
# cat /etc/resolv.conf
    echo "${GREEN} Enable Port forwading${NC}"
sed -i "/enp0s3/d" /etc/sysctl.conf 2>/dev/null >/dev/null
sysctl -w vm.max_map_count=262144  2>/dev/null >/dev/null
sysctl -w net.ipv4.ip_forward=1 2>/dev/null >/dev/null
sudo sh -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.conf" 2>/dev/null >/dev/null
sudo sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf" 2>/dev/null >/dev/null
sudo sysctl -p /etc/sysctl.conf 2>/dev/null >/dev/null
    
echo "Firewall Status"

sudo firewall-cmd --state
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones
systemctl status firewalld && systemctl stop firewalld

# Increase LVM size for root
# yum -y install cloud-utils-growpart && growpart /dev/sda 2; pvresize /dev/sda2; lvextend -l+100%FREE /dev/centos/root; xfs_growfs /dev/centos/root;lsblk

which docker 2>/dev/null && docker --version | grep "Docker version" >/dev/null
if [ $? -eq 0 ]; then
    echo "${GREEN}Docker Existing${NC}"
else
    echo "${RED}Install Docker.......${NC}"
    sudo yum -y install yum-utils device-mapper-persistent-data lvm2 2>/dev/null >/dev/null
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null >/dev/null
    yum clean all 2>/dev/null >/dev/null && yum update all 2>/dev/null >/dev/null
    echo "${GREEN}Installing Docker Packages${NC}"
    yum install -y wget git vim docker-ce iptables docker-ce-cli containerd.io 2>/dev/null >/dev/null
    cat > /etc/docker/daemon.json <<EOF
{
"live-restore": true,
"log-driver": "json-file",
"log-opts": {
"mode": "non-blocking",
"max-buffer-size": "4m",
"max-size": "10m",
"max-file": "3"
}
}
EOF
systemctl daemon-reload
systemctl enable docker 2>/dev/null >/dev/null
systemctl restart docker
    docker version --format '{{.Server.Version}}'
fi

 [ -e /acceldata ] && echo "/acceldata exists" && mv -f /acceldata /acceldata_bk || mkdir -p /acceldata
 

# Cluster Configuration Changes
# https://docs.acceldata.io/pulse/cluster-configuration-changes


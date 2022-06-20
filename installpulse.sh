#!/bin/bash
# Pravin Bhagade

# wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/installpulse.sh && chmod +x installpulse.sh && bash installpulse.sh

# What does script Do:
# Set JAVA_HOME, umask, selinux, sysctl, firewalld, install and setup docker.

# Pulse Setup : https://docs.acceldata.io/pulse/prerequisites
# Minimum Requirement

# Number of Pulse Nodes : 1
# Pulse Server RAM : 64GB
# Number of Pulse Core Servers : 16
# Pulse Server Storage : 1TB

echo "Set JAVA_HOME"

find / -executable -name java
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.332.b09-1.el7_9.x86_64
echo $JAVA_HOME

echo "Set umask"
umask
echo umask 0022 >> /etc/profile

echo "sestatus status" 

sestatus
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


# DNS	Require DNS resolution from Pulse server to cluster nodes or from cluster nodes to Pulse server. Test with nslookup command to check forward and reverse lookup of hosts.
cat /etc/resolv.conf

echo "Sysctl Status"

sysctl -w vm.max_map_count=262144
sysctl -w net.ipv4.ip_forward=1
sudo sh -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.conf"
sudo sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
sudo sysctl -p /etc/sysctl.conf

echo "Firewall Status"

sudo firewall-cmd --state
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones
systemctl status firewalld
systemctl stop firewalld

# Docker without proxy setup

###  Add Docker repository ###
# Install dependencies for docker-ce
sudo yum -y install yum-utils device-mapper-persistent-data lvm2

echo "Added docker repo"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 

yum clean all && yum update all  && yum install -y wget git vim docker-ce iptables docker-ce-cli containerd.io
docker version

# Setup daemon.
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

# Restart Docker
systemctl daemon-reload
systemctl enable docker
systemctl restart docker
systemctl status -l docker

echo umask 0022 >> /etc/profile

mkdir -p /acceldata

# Cluster Configuration Changes
# https://docs.acceldata.io/pulse/cluster-configuration-changes


#!/bin/bash

which docker

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version"
    if [ $? -eq 0 ]
    then
        echo "docker existing"
    else
        echo "install docker"
sudo yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum clean all && yum update all  && yum install -y wget git vim docker-ce iptables docker-ce-cli containerd.io
systemctl enable docker
systemctl restart docker
docker version
    fi
else
    echo "install docker" >&2
fi

## Setup Docker Freeipa

mkdir -p /var/lib/ipa-data

# Enable Port forwading
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
docker build -t freeipa-server -f Dockerfile.centos-7 .
docker images

# docker run  -e IPA_SERVER_IP=<...ip...> --name freeipa-server -ti -h <HOSTNAME> -p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/lib/ipa-data:/data:Z -e PASSWORD=admin-password freeipa-server ipa-server-install -U -r <REALM> --ds-password=admin-password --admin-password=admin-password --domain=<DOMAIN> --no-ntp 

# Note: Else it will keep on running.
# * exit-on-finished  # Once added , make sure to start docker container.
# Example: docker run [...] freeipa-server exit-on-finished -U -r EXAMPLE.TEST


# docker run  -e IPA_SERVER_IP=ip-address--name freeipa-server-test -ti -h hostname.domain.test \
# -p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp \
# --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/lib/ipa-data:/data:Z \
# -e PASSWORD=admin-password freeipa-server ipa-server-install -U -r DOMAIN.TEST \
# --ds-password=admin-password --admin-password=admin-password --domain=domain.test --no-ntp 


# Note:
# Clean up or change data dir " /var/lib/ipa-data" for new configuration

# docker stop freeipa-server
# docker start freeipa-server

# Cleanup container
# docker stop container-id
# docker rm container-id


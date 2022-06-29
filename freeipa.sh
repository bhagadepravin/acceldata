#!/bin/bash

# curl -s https://raw.githubusercontent.com/bhagadepravin/acceldata/main/freeipa.sh | bash

GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

HOSTNAME=`hostname -f`
IP=`hostname -i`
DOMAIN=`hostname -d`
REALM="${DOMAIN^^}"
echo "HOSTNAME=${GREEN}${HOSTNAME}${NC}"
echo "IP=${GREEN}${IP}${NC}"
echo "DOMAIN=${GREEN}${REALM}${NC}"
echo "REALM=${GREEN}${DOMAIN}${NC}"

which docker &&  docker --version | grep "Docker version"

if [ $? -eq 0 ]
then
         echo "${GREEN}Docker Existing${NC}"  
    else
         echo "${RED}Install Docker${NC}"
         sudo yum -y install yum-utils device-mapper-persistent-data lvm2 2>/dev/null >/dev/null
         yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
         yum clean all && yum update all  && yum install -y wget git vim docker-ce iptables docker-ce-cli containerd.io 2>/dev/null >/dev/null
         systemctl enable docker
         systemctl restart docker
         docker version
    fi

         echo "${GREEN} Setup Docker Freeipa${NC}

docker images freeipa-server | grep freeipa-server

if [ $? -eq 0 ]
then
         echo "${GREEN}Freeipa-server image exists ${NC}"  
    else
mv  /var/lib/ipa-data  /var/lib/ipa-data_bk
mkdir -p /var/lib/ipa-data
echo "${GREEN} Enable Port forwading${NC}
sysctl -w net.ipv4.ip_forward=1 2>/dev/null >/dev/null
sudo sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf" 2>/dev/null >/dev/null
sudo sysctl -p /etc/sysctl.conf 2>/dev/null >/dev/null
cd && git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
docker build -t freeipa-server -f Dockerfile.centos-7 .
docker images freeipa-server

echo "HOSTNAME=${GREEN}${HOSTNAME}${NC}"
echo "IP=${GREEN}${IP}${NC}"
echo "DOMAIN=${GREEN}${REALM}${NC}"
echo "REALM=${GREEN}${DOMAIN}${NC}"

docker run  -e IPA_SERVER_IP=${IP} --name freeipa-server -ti -h ${HOSTNAME} \
-p 53:53/udp -p 53:53 -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp \
--sysctl net.ipv6.conf.all.disable_ipv6=0 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/lib/ipa-data:/data:Z \
-e PASSWORD=admin-password freeipa-server ipa-server-install -U -r ${REALM} --ds-password=admin-password --admin-password=admin-password \
--domain=${DOMAIN} --no-ntp 
docker stop freeipa-server
docker start freeipa-server
fi

# Note: Else it will keep on running.
# * exit-on-finished  # Once added , make sure to start docker container.
# Example: docker run [...] freeipa-server exit-on-finished -U -r EXAMPLE.TEST

# ldapsearch -x -h pravin2.sre.iti.acceldata.dev -D "uid=admin,cn=users,cn=accounts,dc=sre,dc=iti,dc=acceldata,dc=dev" -w admin-password \
# -b "cn=users,cn=accounts,dc=sre,dc=iti,dc=acceldata,dc=dev"  dn


echo "${GREEN}FreeIPA WebUI${NC} --- ${RED}https://$HOSTNAME/ipa/ui${NC}"

echo "Add to local machine "$IP $HOSTNAME" >> /etc/hosts"

# docker stop freeipa-server
# docker rm freeipa-server

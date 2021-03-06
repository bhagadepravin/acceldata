#!/bin/bash

# curl -sSL https://raw.githubusercontent.com/bhagadepravin/acceldata/main/kubespray.sh | bash
# around 35mins to install K8 cluster

yum -y install epel-release 2>/dev/null >/dev/null
yum -y update  2>/dev/null >/dev/null
yum -y groupinstall "Development Tools"
yum -y install openssl-devel bzip2-devel libffi-devel xz-devel wget mlocate git 2>/dev/null >/dev/null
if [[ -f "/usr/local/bin/python3.8" ]]
then
    echo "python3.8 is present"
else 
    printf "Downloading Python-3.9.6 tar "
    wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
    tar xvf Python-3.8.12.tgz
    cd Python-3.8*/
    ./configure --enable-optimizations
    sudo make altinstall
    python3.8 --version
    printf "done!\n"
fi

sudo yum -y install gcc gcc-c++ python-virtualenv python-pip python3-pip python-devel libffi-devel openssl-devel libyaml-devel sshpass git vim-enhanced 2>/dev/null >/dev/null
pip3 install virtualenv
pip3 install virtualenvwrapper
cd
#git clone https://github.com/kubernetes-sigs/kubespray.git
[ -d ~/kubespray ] && echo "Github kubespray repo exists" || git clone  https://github.com/bhagadepravin/kubespray.git 2>/dev/null >/dev/null
HOSTNAME=`hostname -f`
IPADDRESS=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
sed -i "s/IPADDRESS/${IPADDRESS}/g" kubespray/inventory/pravincluster/inventory.ini 2>/dev/null >/dev/null
sed -i "s/IPADDRESS/${IPADDRESS}/g" kubespray/inventory/pravincluster/hosts.yaml 2>/dev/null >/dev/null
sed -i "s/HOSTNAME/${HOSTNAME}/g" kubespray/inventory/pravincluster/inventory.ini 2>/dev/null >/dev/null

# Modify few files:https://accelcentral.atlassian.net/wiki/spaces/PCI/pages/156663971/Single+Node+k8s+-+Pulse+On-Prem+Deployment
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
ANSIBLE_VERSION=2.12
virtualenv  --python=$(which python3.8) $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements-$ANSIBLE_VERSION.txt
test -f requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy role install -r requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy collection -r requirements-$ANSIBLE_VERSION.yml
  
 # cp -rfp inventory/sample inventory/pravincluster
 # Review and change parameters under ``inventory/mycluster/group_vars``
echo "vim inventory/pravincluster/group_vars/all/all.yml"
echo "vim inventory/pravincluster/group_vars/k8s_cluster/k8s-cluster.yml"

# Delete any entries which look like below from /etc/sysctl.conf file
# /proc/sys/net/ipv6/conf/all/disable_ipv6=1
# /proc/sys/net/ipv6/conf/default/disable_ipv6
# /proc/sys/net/ipv6/conf/<interface>/disable_ipv6

ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root cluster.yml
  


#++++++++++++++++++++++++
# You can remove node by node from your cluster simply adding specific node do section [kube-node] in inventory/mycluster/hosts.ini file (your hosts file) and run command:
# ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root remove-node.yml

# you can also reset the entire cluster for fresh installation:
# ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root reset.yml

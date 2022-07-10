#!/bin/bash

yum -y install epel-release
yum -y update
yum -y groupinstall "Development Tools"
yum -y install openssl-devel bzip2-devel libffi-devel xz-devel
yum -y install wget
wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
tar xvf Python-3.8.12.tgz
cd Python-3.8*/
./configure --enable-optimizations
sudo make altinstall
python3.8 --version
sudo yum -y install gcc gcc-c++ python-virtualenv python-pip python-devel libffi-devel openssl-devel libyaml-devel sshpass git vim-enhanced
python3 get-pip.py
pip3 install virtualenv
pip3 install virtualenvwrapper
cd
git clone https://github.com/kubernetes-sigs/kubespray.git
# Modify few files:https://accelcentral.atlassian.net/wiki/spaces/PCI/pages/156663971/Single+Node+k8s+-+Pulse+On-Prem+Deployment
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
ANSIBLE_VERSION=2.11
virtualenv  --python=$(which python3.8) $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements-$ANSIBLE_VERSION.txt
test -f requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy role install -r requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy collection -r requirements-$ANSIBLE_VERSION.yml
  
 cp -rfp inventory/sample inventory/pravincluster
 # Review and change parameters under ``inventory/mycluster/group_vars``
echo "vim inventory/pravincluster/group_vars/all/all.yml\n"
echo "vim inventory/pravincluster/group_vars/k8s_cluster/k8s-cluster.yml\n"

# Delete any entries which look like below from /etc/sysctl.conf file
# /proc/sys/net/ipv6/conf/all/disable_ipv6=1
# /proc/sys/net/ipv6/conf/default/disable_ipv6
# /proc/sys/net/ipv6/conf/<interface>/disable_ipv6

# ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root cluster.yml
  


#++++++++++++++++++++++++
# You can remove node by node from your cluster simply adding specific node do section [kube-node] in inventory/mycluster/hosts.ini file (your hosts file) and run command:
# ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root remove-node.yml

# you can also reset the entire cluster for fresh installation:
# ansible-playbook -i inventory/pravincluster/hosts.yaml  --become --become-user=root reset.yml

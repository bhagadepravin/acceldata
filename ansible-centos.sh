#!/bin/bash
#Centos Ansible HDP setup


# hostnamectl set-hostname --static pravin1.sre.iti.acceldata.dev
# hostnamectl set-hostname --static pravin2.sre.iti.acceldata.dev
# hostnamectl set-hostname --static pravin3.sre.iti.acceldata.dev

# echo "10.90.6.153 pravin1.sre.iti.acceldata.dev" >> /etc/hosts
# echo "10.90.6.154 pravin2.sre.iti.acceldata.dev" >> /etc/hosts

# Setup root login for ssh if not working
# echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
# sudo systemctl restart sshd

sudo yum -y install epel-release || sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum --nogpgcheck -y install bind-utils nc ntp net-tools sysstat tcpdump strace python3  bzip2-devel java-1.8.0-openjdk-devel mysql-connector-java gcc gcc-c++ python-virtualenv htop python3-pip python3-devel libffi-devel openssl-devel libyaml-devel sshpass git vim-enhanced git mlocate 




# Install python3.9 "This will take sometime to configure"

wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
tar -xvf Python-3.9.6.tgz
cd Python-3.9.6 
./configure --enable-optimizations
sudo make altinstall
python3.9 --version

# Optional
touch ~/.bash_aliases
echo "alias python3='/usr/local/bin/python3.9'" >> ~/.bash_aliases
source ~/.bash_aliases
python3 -V


# --python=
virtualenv --python=/usr/local/bin/python3.9 ~/ansible; source ~/ansible/bin/activate
# virtualenv ~/ansible; source ~/ansible/bin/activate

pip3 install setuptools --upgrade
pip3 install pip --upgrade   
pip3 install ansible

wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/set_passwordless_ssh.sh && chmod +x set_passwordless_ssh.sh

# ./set_passwordless_ssh IP-ADDRESS


cd && git clone https://github.com/bhagadepravin/ansible-hortonworks.git

# Modify the file at ~/ansible-hortonworks/inventory/static

# ansible -i ~/ansible-hortonworks/inventory/static all --list-hosts
# ansible -i ~/ansible-hortonworks/inventory/static all -m setup


# Cluster config
# Modify the file at ~/ansible-hortonworks/playbooks/group_vars/all
# https://github.com/hortonworks/ansible-hortonworks/blob/master/INSTALL_static.md#cluster-config-file

# Install the cluster : https://github.com/hortonworks/ansible-hortonworks/blob/master/INSTALL_static.md#install-the-cluster

export CLOUD_TO_USE=static
# cd ~/ansible-hortonworks*/ && bash install_cluster.sh


# Prepare the nodes: prepare_nodes.sh
# Install Ambari: install_ambari.sh
# Configure Ambari: configure_ambari.sh
# Apply Blueprint: apply_blueprint.sh
# Post Install: post_install.sh

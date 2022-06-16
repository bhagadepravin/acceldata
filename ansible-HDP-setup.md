# Setup HDP Cluster Using Ansible.

* Ambari `2.7.4.0-118`
* HDP `3.1.4.0-315`

## Setup Mac Workstation. One time setup.
1. Install the required packages
```python
brew install python
brew install git
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
pip3 install virtualenv
pip3 install virtualenvwrapper
```

2. Create and source the Python virtual environment
```python
virtualenv -p /usr/bin/python3 ~/ansible; source ~/ansible/bin/activate
```	
3. Install the required Python packages inside the virtualenv
```python
pip install setuptools --upgrade
pip install pip --upgrade
pip install ansible openstacksdk
```
4. The build node / workstation will need to login via SSH to the cluster nodes.
   Setup passwordless ssh to the nodes.
```bash   
wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/set_passwordless_ssh.sh  && chmod +x set_passwordless_ssh.sh
```
### Create a host file with all host entry for the cluster which you want to creat.
```bash
vi hosts
10.90.6.81
10.90.6.91
10.90.6.93
10.90.6.94
10.90.6.95
```

### Setting password-less ssh from mac to cluster nodes.
```bash
while read HOST; do bash set_passwordess_ssh.sh $HOST user ;done <hosts
```
## Clone GitHub repo, which include ansible related files

```bash
git clone https://github.com/bhagadepravin/ansible-hortonworks.git
```
Update Hostname and ipaddress to Mac Machine under /etc/hosts.

# Cluster Configs / Start from here if Mac workstation setup is already done for ansible

#### Set the static inventory
Modify the file at `~/ansible-hortonworks/inventory/static` to set the static inventory, or create a cluster specific one

### Repo details 
Cross Check `~/ansible-hortonworks/playbooks/roles/ambari-config/defaults/main.yml`

#### For Ubuntu user ansible_user as "user"
Example: for 5 node cluster
```bash
[hdp-master]
master01 ansible_host=mstr1.hdp310.u18.adsre ansible_user=user ansible_ssh_private_key_file="~/.ssh/id_rsa" rack=/default-rack

[hdp-slave01]
slave01 ansible_host=mstr2.hdp310.u18.adsre ansible_user=user ansible_ssh_private_key_file="~/.ssh/id_rsa" rack=/default-rack
[hdp-slave02]
slave02 ansible_host=cmpt1.hdp310.u18.adsre ansible_user=user ansible_ssh_private_key_file="~/.ssh/id_rsa" rack=/default-rack
slave03 ansible_host=cmpt2.hdp310.u18.adsre ansible_user=user ansible_ssh_private_key_file="~/.ssh/id_rsa" rack=/default-rack
slave04 ansible_host=cmpt3.hdp310.u18.adsre ansible_user=user ansible_ssh_private_key_file="~/.ssh/id_rsa" rack=/default-rack
```


Test ansible cmds, First switch to virtual env.

```bash
virtualenv -p /usr/bin/python3 ~/ansible; source ~/ansible/bin/activate

ansible -i ~/ansible-hortonworks/inventory/static all --list-hosts
ansible -i ~/ansible-hortonworks/inventory/static all -m setup
ansible -i ~/ansible-hortonworks/inventory/static all -m setup | grep ansible_fqdn
```

Modify the file at ` ~/ansible-hortonworks/playbooks/group_vars/all`

Modify below variables:

```bash
cluster_name
security
http_authentication
ambari_admin_password
default_password
host_group
```
`host_group` Distribute the services accordingly.
Sample files, make sure you edit/update in `all` file:  https://github.com/bhagadepravin/ansible-hortonworks/tree/master/playbooks/group_vars

```bash
egrep "cluster_name|security:|http_authentication|ambari_admin_password|host_group"  ~/ansible-hortonworks/playbooks/group_vars/all
```
Goto host_group section to devide the services.
As currently we have 5 node.


## run ansible to setup cluster
```bash
virtualenv -p /usr/bin/python3 ~/ansible; source ~/ansible/bin/activate
export CLOUD_TO_USE=static
cd ~/ansible-hortonworks*/ && bash install_cluster.sh
```

## or You can perform activity one by one

```bash
bash prepare_nodes.sh
bash install_ambari.sh
bash configure_ambari.sh
bash apply_blueprint.sh
bash post_install.sh
```

On `YARN_REGISTRY_DNS` node stop below service.
```
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

Regenerate Kerberos keytab onces and restart whole cluster
Check /etc/hosts file on all hosts and "hostname -f" cmd output

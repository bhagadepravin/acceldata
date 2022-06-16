# Setup HDP Cluster Using Ansible.

* Ambari `2.7.4.0-118`
* HDP `3.1.4.0-315`

- Setup Mac Workstation. One time setup
- [Clone GitHub repo](https://github.com/bhagadepravin/acceldata/blob/main/ansible-HDP-setup.md#clone-github-repo-which-include-ansible-related-files)
- [Install cluster](https://github.com/bhagadepravin/acceldata/blob/main/ansible-HDP-setup.md#install-the-cluster)


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
### Create a host file with all host entry of the cluster which you want to create.
ex:
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
cd && git clone https://github.com/bhagadepravin/ansible-hortonworks.git
```
Update Hostname and ipaddress to Mac Machine under /etc/hosts.

# Cluster Configs / Start from here if Mac workstation setup is already done for ansible

#### Set the static inventory
Modify the file at `~/ansible-hortonworks/inventory/static` to set the static inventory.

The static inventory puts the nodes in different groups as described in the [Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#hosts-and-groups).

#### For Ubuntu user ansible_user as "user", For CentOS user use "root" user
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


## Set the cluster variables

### cluster config file

Modify the file at `~/ansible-hortonworks/playbooks/group_vars/all` to set the cluster configuration.

| Variable                   | Description                                                                                                 |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| cluster_name               | The name of the cluster.                                                                                    |
| ambari_version             | The Ambari version, in the full, 4-number form, for example: `2.6.2.2`.                                     |
| hdp_version                | The HDP version, in the full, 4-number form, for example: `2.6.5.0`.                                        |
| hdp_build_number           | The HDP build number for the HDP version above, which can be found on the Stack Repositories page from [docs.hortonworks.com](https://docs.hortonworks.com). If left to `auto`, Ansible will try to get it from the repository [build.id file](https://github.com/hortonworks/ansible-hortonworks/blob/master/playbooks/roles/ambari-config/tasks/main.yml#L141) so this variable only needs changing if there is no build.id file in the local repository that is being used. |
| repo_base_url              | The base URL for the repositories. Change this to the local web server url if using a Local Repository. `/HDP/<OS>/2.x/updates/<latest.version>` (or `/HDF/..`) will be appended to this value to set it accordingly if there are additional URL paths. |

### java configuration

| Variable                   | Description                                                                                                 |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| java                       | Can be set to `embedded` (default - downloaded by Ambari), `openjdk` or `oraclejdk`. If `oraclejdk` is selected, then the `.x64.tar.gz` package must be downloaded in advance from [Oracle](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html). Same with the [JCE](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html) package. These files can be copied to all nodes in advanced or only to the Ansible Controller and Ansible will copy them. This behaviour is controlled by the `oraclejdk_options.remote_files` setting. |
| oraclejdk_options          | These options are only relevant if `java` is set to `oraclejdk`. |

### database configuration

| Variable                                 | Description                                                                                                |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| database                                 | The type of database that should be used. A choice between `embedded` (Ambari default), `postgres`, `mysql` or `mariadb`. |
| database_options                         | These options are only relevant for the non-`embedded` database. |

### kerberos security configuration

| Variable                       | Description                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| security                       | This variable controls the Kerberos security configuration. If set to `none`, Kerberos will not be enabled. Otherwise the choice is between `mit-kdc` or `active-directory`. |
| security_options               | These options are only relevant if `security` is not `none`. All of the options here are used for an Ambari managed security configuration. No manual option is available at the moment. |
| `.http_authentication`         | Set to `yes` to enable Kerberos HTTP authentication (SPNEGO) for most UIs. |



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



# Install the cluster

Run the script that will install the cluster using Blueprints while taking care of the necessary prerequisites.

Make sure you set the `CLOUD_TO_USE` environment variable to `static`.

```
virtualenv -p /usr/bin/python3 ~/ansible; source ~/ansible/bin/activate
export CLOUD_TO_USE=static
cd ~/ansible-hortonworks*/ && bash install_cluster.sh
```


This script will apply all the required playbooks in one run, but you can also apply the individual playbooks by running the following wrapper scripts:

- Prepare the nodes: `prepare_nodes.sh`
- Install Ambari: `install_ambari.sh`
- Configure Ambari: `configure_ambari.sh`
- Apply Blueprint: `apply_blueprint.sh`
- Post Install: `post_install.sh`


On `YARN_REGISTRY_DNS` node stop below service.
```
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

Regenerate Kerberos keytab onces and restart whole cluster
Check /etc/hosts file on all hosts and "hostname -f" cmd output

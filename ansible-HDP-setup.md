# Setup HDP Cluster Using Ansible.

* Ambari `2.7.4.0-118`
* HDP `3.1.4.0-315`

- Setup Mac Workstation. One time setup
- [Clone GitHub repo](https://github.com/bhagadepravin/acceldata/blob/main/ansible-HDP-setup.md#clone-github-repo-which-include-ansible-related-files)

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
| `.external_hostname`                     | The hostname/IP of the database server. This needs to be prepared as per the [documentation](https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.2/bk_ambari-administration/content/ch_amb_ref_using_existing_databases.html). No need to load any schema, this will be done by Ansible, but the users and databases must be created in advance. If left empty `''` then the playbooks will install the database server on the Ambari node and prepare everything with the settings defined bellow. To change any settings (like the version or repository path) modify the OS specific files under the `playbooks/roles/database/vars/` folder. |
| `.add_repo`                              | If set to `yes`, Ansible will add a repo file pointing to the repository where the database packages are located (by default, the repo URL is public). Set this to `no` to disable this behaviour and use repositories that are already available to the OS. |
| `.ambari_db_name`, `.ambari_db_username`, `.ambari_db_password` | The name of the database that Ambari should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.hive_db_name`, `.hive_db_username`, `.hive_db_password`       | The name of the database that Hive should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.oozie_db_name`, `.oozie_db_username`, `.oozie_db_password`    | The name of the database that Oozie should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.druid_db_name`, `.druid_db_username`, `.druid_db_password`    | The name of the database that Druid should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.superset_db_name`, `.superset_db_username`, `.superset_db_password`          | The name of the database that Superset should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.rangeradmin_db_name`, `.rangeradmin_db_username`, `.rangeradmin_db_password` | The name of the database that Ranger Admin should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.rangerkms_db_name`, `.rangerkms_db_username`, `.rangerkms_db_password`       | The name of the database that Ranger KMS should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.registry_db_name`, `.registry_db_username`, `.registry_db_password`          | The name of the database that Schema Registry should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |
| `.streamline_db_name`, `.streamline_db_username`, `.streamline_db_password`    | The name of the database that SAM should use and the username and password to connect to it. If `database_options.external_hostname` is defined, these values will be used to connect to the database, otherwise the Ansible playbook will create the database and the user. |

### kerberos security configuration

| Variable                       | Description                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| security                       | This variable controls the Kerberos security configuration. If set to `none`, Kerberos will not be enabled. Otherwise the choice is between `mit-kdc` or `active-directory`. |
| security_options               | These options are only relevant if `security` is not `none`. All of the options here are used for an Ambari managed security configuration. No manual option is available at the moment. |
| `.external_hostname`           | The hostname/IP of the Kerberos server. This can be an existing Active Directory or [MIT KDC](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_security/content/_optional_install_a_new_mit_kdc.html). If left empty `''` then the playbooks will install the MIT KDC on the Ambari node and prepare everything. |
| `.realm`                       | The realm that will be used when creating service principals. |
| `.admin_principal`             | The Kerberos principal that has the permissions to create new users. No need to append the realm to this value. In case of Active Directory, this user must have `Create, delete, and manage user accounts` permissions over the OU container. If installing a new MIT KDC this user will be created by the playbook. |
| `.admin_password`              | The password for the above user. |
| `.kdc_master_key`              | The master password for the Kerberos database. Only used when installing a new MIT KDC (when `security` is `mit-kdc` and `external_hostname` is set to `''`. |
| `.ldap_url`                    | The URL to the Active Directory LDAPS interface. Only used when `security` is set to `active-directory`. |
| `.container_dn`                | The distinguished name (DN) of the container that will store the service principals. Only used when `security` is set to `active-directory`. |
| `.http_authentication`         | Set to `yes` to enable Kerberos HTTP authentication (SPNEGO) for most UIs. |

### ranger configuration

| Variable                       | Description                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| ranger_options                 | These options are only relevant if `RANGER_ADMIN` is a component of the dynamic Blueprint stack.           |
| `.enable_plugins`              | If set to `yes` the plugins for all of the available services will be enabled. With `no` Ranger would be installed but not functional. |
| ranger_security_options        | Security related options for Ranger (such as passwords).                                                   |
| `.ranger_admin_password`       | The password for the Ranger admin users (both admin and amb_ranger_admin).                                 |
| `.ranger_keyadmin_password`    | The password for the Ranger keyadmin user. This only has effect in HDP3, with HDP2 the password will remain to the default of `keyadmin` and must be changed manually. |
| `.kms_master_key_password`     | The password used for encrypting the Master Key.    

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

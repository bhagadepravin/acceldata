<p align="center">
  <a href="https://www.acceldata.io">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/213919961-56b0dfbf-a5a4-45b1-aa16-ec5f6fd1ac78.png" />
  </a>
</p>
<h1 align="center">
   Enterprise Data Observability for the Modern Data Stack <br/>
</h1>


1. [Pulse File Explorer / ad-fsanalitics Container: HDFS fsimage Access Error Solution..](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#1-pulse-file-explorer--ad-fsanalitics-container-hdfs-fsimage-access-error-solution)
2. [Upgrading a Docker Image with a Tar File: Download, Load, Replace](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#2-upgrading-a-docker-image-with-a-tar-file-download-load-replace)
3. [Troubleshooting LogSearch UI on Pulse Server](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#3-troubleshooting-logsearch-ui-on-pulse-server)
4. [Enable SSL/Kerberos debug logging for container](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#4-enable-sslkerberos-debug-logging-for-container)
5. [Add Multple Clusters to existing Pulse server](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#5-add-multple-clusters-to-existing-pulse-server)
6. [Add a Node to existing Pulse Server](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#6-add-a-node-to-existing-pulse-server)
7. [How to remove a node from Pulse server](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#7-how-to-remove-a-node-from-pulse-server)
8. [Pulse auto reconfigure not working after enabling SSL on Ambari?](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#8-what-to-do-if-ambari-ssl-is-enabled-after-pulse-setup)
9. [Pulse LDAP setup with Active Directory with group mapping.](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#9-pulse-ldap-setup-with-active-directory-with-group-mapping)
## 1. Pulse File Explorer / ad-fsanalitics Container: HDFS fsimage Access Error Solution.

When trying to download the HDFS fsimage, the hdfs headless user is encountering a 403 error:

```bash
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<title>Error 403 Only Namenode, Secondary Namenode, and administrators may access this servlet</title>
</head>
<body><h2>HTTP ERROR 403</h2>
<p>Problem accessing /imagetransfer. Reason:
<pre>    Only Namenode, Secondary Namenode, and administrators may access this servlet</pre></p><hr /><i><small>Powered by Jetty://</small></i><br/>
```

The solution to this issue is to use the HDFS nn service principal from the HDFS active namenode instead of the hdfs headless principal.


<details>
<summary>If you want to verify which user has access to download FSimage, you can use the following command</summary>
<br>
Login into Hadoop node and execute below cmds.
  
$ kinit user
  
$ hdfs dfsadmin -fetchImage /tmp

* once its downloaded you can delete fsimage from /tmp location
* users part of *dfs.cluster.administrators* property in HDFS can download fsimage
* Here nn service principal works, because, HDFS auth_to_local rules converts nn service principal to hdfs before authentication to hdfs.
* RULE:[2:$1@$0](nn@REALM.COM)s/.*/hdfs/
</details>

------------

1. Get the `nn.service.keytab` file from the HDFS active namenode's `/etc/security/keytab/` directory
2. Copy the keytab file to the Pulse Server node
3. Go to the AcceloHome directory:
```
$ cd $AcceloHome
$ cd work/<CLUSTER_NAME>/fsanalytics/
```
4. Update the following two scripts with the nn service principal:

**Example**: Using the Namenode service principal `nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM`
* a. update_fsimage.sh
* b. kinit_fsimage.sh

```bash
$ cat kinit_fsimage.sh
#!/bin/bash

kinit -kt /krb/security/kerberos.keytab nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM
IsKerberosEnabled=1
```

```bash
update_fsimage.sh

  /usr/bin/gurl -X GET -u "hdfs:" -k -kt /krb/security/kerberos.keytab -kp nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM -o /etc/fsanalytics/$1/fsimage -l "http://hdp314-lab2.iti.acceldata.dev:50070/imagetransfer?getimage=1&txid=latest"
```

**Note:** In customer case use the below command to check the Namenode service principal
```
$ klist -kt /etc/security/keytab/nn.service.keytab
```
5. Navigate to the `ad-fsanalyticsv2-connector.yml` file located in the `<$AcceloHome>/config/docker/addons` directory.

6. If not present, Generate the `ad-fsanalyticsv2-connector.yml` configuration file by executing the command

`$ accelo admin makeconfig ad-fsanalyticsv2-connector`

7. Add a new mount under the **volumes:** section. You can copy the nanenode service keytab under the directory:
`$ cp nn.service.keytab $AcceloHome/config/krb/security`
Update the new `nn.service.keytab` to `ad-fsanalyticsv2-connector` container, we need to add mount point for keytab.


`$ vi ad-fsanalyticsv2-connector.yml`
The mount point should look like this (replace the actual `$AcceloHome` path):
```bash
    - $AcceloHome/config/krb/security/nn.service.keytab:/krb/security/kerberos.keytab
```

8. Restart ad-fsanalyticsv2-connector and Load the fsimage again
```
accelo restart ad-fsanalyticsv2-connector
accelo admin fsa load
docker logs -f ad-fsanalyticsv2-connector_default
```

Once these steps are completed, the HDFS fsimage should be able to be downloaded without any 403 errors.

9. Troubleshoot:
```bash
docker logs -f ad-fsanalyticsv2-connector_default
docker logs -f ad-connectors_default

# Check fsimage
curl -X GET http://localhost:19013/_cat/indices?v |grep fsimage

# Delete fsimage and load it again
curl -X DELETE http://localhost:19013/*fsimage*
accelo restart ad-fsanalyticsv2-connector
accelo admin fsa load
docker logs -f ad-fsanalyticsv2-connector_default
```

##### Any socket timeout related error
add these in `ad-fsanalyticsv2-connector.yml` file `$AcceloHome/config/docker/addons` folder
```
ES_CLIENT_SOCKET_TIMEOUT_SECS=120
ES_CLIENT_CONNECT_TIMEOUT_SECS=120
ES_CLIENT_MAX_RETRY_TIMEOUT_SECS=120
```

##### Modify JVM memory of FS Analytics

Update property `JAVA_OPTS=-XX:+UseG1GC -XX:+UseStringDeduplication -Xms<VALUE>g -Xmx<VALUE>g`, 

here value will be equivalent to 4 times the FS Image size, save the file and restart ad-fsanalyticsv2-connector:

https://docs.acceldata.io/pulse/change-component-resource-limit#modify-jvm-memory-of-fs-analytics


## 2. Upgrading a Docker Image with a Tar File: Download, Load, Replace

1. Download the new `image.tar` file:
```
$ wget https://example.com/image.tar
```

2. Load the image
```
$ docker load -i image.tar
```

3. To delete the container image with a specific tag version, use the command:
```bash
$ docker images 
# This will list all the images. Replace the repository and tag name of the image that you want to delete.
$ docker rmi  REPOSITORY:TAG
```

4. To change the image tag of a container from a new tag to an old tag, use the command:
```bash
$ docker tag REPOSITORY:NEW_TAG  REPOSITORY:OLD_TAG
# You can check the image with the new tag by running
$ docker images 
```
5. Restart the container to use the new image
```
$ accelo restart CONTAINER_NAME
```
With these steps, you will be able to download the latest tar docker image, load it, and replace it with the old image.

## 3. Troubleshooting LogSearch UI on Pulse Server

###### If LogSearch UI is missing any service logs such as datanode or resourcemanager, follow these steps to troubleshoot:

1. Log in to the respective service node on the Hadoop cluster.
2. Check the following log file:
```bash
$ cat /opt/pulse/logs/log/messages
```
The `pulselogs` agent is responsible for sending data to Logstash and Elastic.

#### Enable debug logging for the pulselog agent by editing the `logs.yml` file:
```bash
$ vi /opt/pulse/logs/config/logs.yml
```
* Search for "level" and change it from "info" to "debug".
* Restart the `pulselogs` service.

```bash
$ service pulselogs status
$ service pulselogs restart
```
#### Collect docker logs:
ad-streaming container is required for Logsearch to work.
```bash
docker ps
docker logs ad-elastic_default 
docker logs ad-logstash_default
docker logs ad-logsearch-curator_default
```
```bash
for container in "ad-logstash" "ad-connectors" "ad-elastic" "ad-streaming" "ad-logsearch-curator" "ad-graphql"; do 
  echo "$(date +%Y-%m-%d-%H:%M:%S) $(hostname)" >> /tmp/"$container"_default.log;
  docker logs "$container"_default >> /tmp/"$container"_default.log 2>&1
done
tar cvzf /tmp/pulse_logs.tar.gz /tmp/ad-* 2> /dev/null
```
Attach the `/tmp/pulse_logs.tar.gz` file to your support request.

* `ad-logstash` - used for parsing not for storage
* `ad-logsearch-curator` - used for pruging older indices


#### Check logsearch indices
```sql
curl -X GET http://localhost:19013/_cat/indices
```
* Check log specific indices
example: datanode logs
```sql
curl -X GET http://localhost:19013/_cat/indices?v    | grep "hdfs_datanode"
```
* Here is a sample query in Elasticsearch to retrieve data from the specified indices:
```sql
curl -X GET "http://localhost:19013/hdp310-logs-hdfs_datanode-error-2023.01.26/_search?pretty"
```

```sql
$ curl -X GET http://localhost:19013/_cat/indices?v    | grep "hdfs_datanode-error"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 18432  100 18432    0     0  99389      0 --:--:-- --:--:-- --:--:--   97k
green  open   hdp310-logs-hdfs_datanode-error-2023.01.27       XWsgSXLMTOC4uuE5kPjJsg   3   0       4306            0      1.4mb          1.4mb
green  open   hdp310-logs-hdfs_datanode-error-2023.01.26       xnmj0FMNSzKDaec029NhyA   3   0       4317            0      1.4mb          1.4mb
green  open   hdp310-logs-hdfs_datanode-error-2023.01.30       YqEcM40NRU6K2Ub1EXs2yg   3   0       3217            0      2.1mb          2.1mb
green  open   hdp310-logs-hdfs_datanode-error-2023.01.28       7EypegR-RIS2hagVrSviag   3   0       4317            0      1.2mb          1.2mb
green  open   hdp310-logs-hdfs_datanode-error-2023.01.29       D1a-j7ApQw2MMmrrVB5Z_w   3   0       4316            0      1.3mb          1.3mb
```

```sql
$ curl -X GET "http://localhost:19013/hdp310-logs-hdfs_datanode-error-2023.01.26/_search?pretty"
100 20381  100 20381    0     0  2181k      0 --:--:-- --:--:-- --:--:-{     0
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 3,
    "successful" : 3,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 4317,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "hdp310-logs-hdfs_datanode-error-2023.01.26",
        "_type" : "doc",
        "_id" : "zcU36oUBFcSp6JqAGWSj",
        "_score" : 1.0,
        "_source" : {
          "message" : "hdp310-lab3.iti.acceldata.dev:1019:DataXceiver error processing unknown operation  src: /10.90.6.157:44920 dst: /10.90.6.157:1019\njava.io.EOFException\n\tat java.io.DataInputStream.readInt(DataInputStream.java:392)\n\tat org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferServer.doSaslHandshake(SaslDataTransferServer.java:361)\n\tat org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferServer.getEncryptedStreams(SaslDataTransferServer.java:180)\n\tat org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferServer.receive(SaslDataTransferServer.java:112)\n\tat - 2487k
org.apache.hadoop.hdfs.server.datanode.DataXceiver.run(DataXceiver.java:232)\n\tat java.lang.Thread.run(Thread.java:750)",
          "logger_name" : "datanode.DataNode ",
          "log" : {
            "flags" : [
              "multiline"
            ],
            "file" : {
              "path" : "/var/log/hadoop/hdfs/hadoop-hdfs-root-datanode-hdp310-lab3.iti.acceldata.dev.log"
            }
          },
          "file" : "DataXceiver.java",
          "host" : {
            "name" : "hdp310-lab3.iti.acceldata.dev"
          },
          "memsql_query_output_enable" : "false",
          "source" : "/var/log/hadoop/hdfs/hadoop-hdfs-root-datanode-hdp310-lab3.iti.acceldata.dev.log",
          "date" : "2023-01-26 00:05:48,009",
          "ignore_older_logs_enable" : "true",
          "fields" : {
            "component" : [
              "hdfs_datanode"
            ],
            "clusterName" : "hdp310"
          },
          "method" : "run",
          "line_number" : "321",
          "@timestamp" : "2023-01-26T00:05:48.009Z",
          "offset" : 182106153,
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "loglevel" : "ERROR"
        }
      },
```

* Here is an example Elasticsearch query to search for documents containing the field `loglevel` with a value of `ERROR`:
replace the index_name
```sql
curl -X GET "http://localhost:19013/index_name/_search?pretty" -H 'Content-Type: application/json' -d'
{
    "query": {
        "match": {
            "loglevel": "ERROR"
        }
    }
}
'
```

* To sort Elasticsearch results for the indices in the above example, you can add a sort parameter to your query. 
For example: or "order": "asc"
```sql
curl -X GET "localhost:19013/index_name/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "sort": [
    {
      "@timestamp": {
        "order": "desc"
      }
    }
  ]
}
'
```

#### For browser-related data collection, please follow these steps:

* Open the Developer Tool in your browser
* Reproduce the issue
* Download the HAR file
* Follow the steps in the following link: https://support.zendesk.com/hc/en-us/articles/4408828867098-Generating-a-HAR-file-for-troubleshooting

Please provide this log files and har file with your support request for troubleshoot the LogSearch UI in Hadoop Cluster.

## 4. Enable SSL/Kerberos debug logging for container.

To add an SSL debug parameter in a Docker container file, you can add the following line to the `environment` section of the container configuration/yml file:

```java
## SSL debug
- JAVA_OPTS=-Djavax.net.debug=ssl
or 
- JAVA_OPTS=-Djavax.net.debug=all

## Krberos debug
- JAVA_OPTS=-Dsun.security.krb5.debug=true
```

```bash
docker exec -it ad-fsanalyticsv2-connector_default sh

Get the output of below cmds.

cd /opt/docker/work/CLUSTER_NAME/fsanalytics
cat kinit_fsimage.sh

export KRB5_TRACE=/dev/stdout
bash kinit_fsimage.sh
klist -e 

bash update_fsimage.sh CLUSTER_NAME
Example:
bash update_fsimage.sh hdp265

env
cat /krb/security/krb5.conf
```

## 5. Add Multple Clusters to existing Pulse server.

**NOTE**

- All the clusters should be homogenous - meaning one type of deployment - HDP/CDP/Standalone. It's should be one of them.
- None of the cluster nodes of all the clusters should be overlapping. Otherwise hydra agent installation will have issues.
- Make sure Pulse Server has resources good enough to hold multiple clusters data - related to retention of data.

This code appears to be a set of command line interface (CLI) commands for configuring and managing clusters using Accelo. 

- `$ accelo config cluster` allows the user to configure a cluster.
- `$ accelo set` sets the configuration.
- Upon running `$ accelo config cluster`, the user will be prompted to select a new cluster from the options provided. The selected cluster will be activated.
- `$ accelo reconfig cluster` is used to reconfigure the cluster.
- `$ accelo deploy hydra` deploys the hydra agent.
- If any issues arise,run the following commands: 
  - `$ accelo admin database push-config`
  - `$ accelo restart all`

## 6. Add a Node to existing Pulse Server

Below instructions for adding a node to an existing Pulse server:

- First, log in to the Pulse server node and reconfigure the cluster by running `$ accelo reconfig cluster`.
- Before proceeding, make a backup of the `hydra_hosts.yml` file located at `$AcceloHome/work/<CLUSRTER_NAME>/`.
- Add only the host which was added recently and remove any existing hosts from the backup file.
- Deploy the Hydra agent with the command `$ accelo deploy hydra`.
- Once agents are deployed on new hosts, revert back the `hydra_hosts.yml` file located at `$AcceloHome/work/<CLUSRTER_NAME>/`.

## 7. How to remove a node from Pulse server

Below instructions for removing a node from a Pulse server and reconfiguring the cluster:

- First, log in to the node that needs to be removed and run the command `$ /opt/pulse/hystaller uninstall` to uninstall the Pulse Agents.
- Next, log in to the Pulse server node and reconfigure the cluster by running `$ accelo reconfig cluster`. This will remove the hosts from the following configuration files:
  - `work/<ClusterName>/alerts/endpoints/default-endpoints.yml`
  - `work/<ClusterName>/hydra_hosts.yml`
  - `work/<ClusterName>/agents/node/hostRoleMap.yml`
- Push the database configuration changes by running `$ accelo admin database push-config`.
- Finally, restart all nodes using the command `$ accelo restart all -d`.


## 8. What to do if Ambari SSL is enabled after Pulse Setup?

**Pulse auto reconfigure not working after enabling SSL on Ambari?**

This auto reconfigure feature allows users to generate the Pulse configuration files without manual user intervention.

To achieve auto reconfigure we will need the credentials to be stored in the Pulse machine (encrypted). As a migration / initial step the user will generate a file which contains the required information for the reconfiguration to work for each cluster configured in Pulse.

The user should run the command `accelo admin dist-store` command. Follow the below steps to complete this migration.

1. To generate a sample config file. Run the command `accelo admin dist-store` .

2. This will generate the `distSecStore.yml` file inside the `<$AcceloHome>` directory. 

    a. Sample `distSecStore.yml` file below with the Fields and their description

```
DistStore:
  Cluster1:
    DistType: hdp    ------ DistType values are ["hdp","cdh","standalone","custom","none"]
    ClusterName: democluster1 ----- This is the clustername used by the CLI to create dirs in the work dir and the database names
    ClusterOriginalName: Cluster1 ---- This is represents the Clustername given to the cluster in the Ambari or Cloudera
    ClusterType: Ambari ---- This represents the type of cluster values: ["Ambari", "Cloudera", "StandAlone", "Custom"]
    ClusterVersion: "3.0.1" --- This represents the ClusterVersion
    DisplayName: Cluster1 ------ This is the clustername that you want to display in the Pulse UI
    IsEdgeNode: false ------ If the Pulse Node is included in the Cluster --- Cloudera/Ambari
    URI: http://host_ip:port ----- Cloudera/Ambari Host with the proper port
    User: admin ----- Username used to login to the Cloudera/Ambari Managers
    Password: admin 
    Proxy: "" ----- URL of the proxy used to login to the Cloudera/Ambari Manager
    SecProxy: false ---- Set to true if there is proxy involved
    ProxyUser: ""  ----- Username to authorize the Proxy
    ProxyPassword: ""  ----- Password of the Proxy
```


3. Now edit the above-generated file and fill in the correct information about each cluster such as Distro login credentials, ClusterName (Used for creating the work directory), ClusterDisplayName (given at the time of configuring core or get it from the acceldata_<ClusterName>.conf file).

4. Once all the required details are filled in run the command `accelo admin dist-store -m` to create the `.dist` files in the correct `cluster name` directories inside the work directory. This file is encrypted and will be kept read-only. 

You will now be able to reconfigure the clusters.`

## 9. Pulse LDAP setup with Active Directory with group mapping.
Ref: https://docs.acceldata.io/pulse/ldap
```sh
  ldap {
  configuration  {
    # The Ldap host
    host = "samba.activedirectory.adsre.com:636",
    # The following field is required if using port 389.
    insecureNoSSL = false
    insecureSkipVerify = true
    rootCA = "/etc/dex/ldap.ca",
    bindDN = "Administrator@ADSRE.COM",
    bindPW = "Welcome@12345",
    specialSearch = true,
    prefix = "CN=",
    suffix = ",OU=users,OU=hadoop,DC=adsre,DC=com",
    userSearch  {
      # Would translate to the query "(&(objectClass=person)(uid=<username>))"
      baseDN = "OU=users,OU=hadoop,DC=adsre,DC=com",
      filter = "(objectClass=person)",
      username = "sAMAccountName",
      idAttr = "sAMAccountName",
      emailAttr = "mail",
      nameAttr = "name"
      # Can be 'sub' or 'one'
      scope = "sub"
    }
    groupSearch  {
      # Would translate to the query "(&(objectClass=group)(member=<user uid>))"
      baseDN = "OU=groups,OU=hadoop,DC=adsre,DC=com",
      filter = "(objectClass=group)",
      # Use if full DN is needed and not available as any other attribute
      # Will only work if "DN" attribute does not exist in the record
      # userAttr: DN
      userAttr = "name",
      groupAttr = "member",
      nameAttr = "name"
      # Can be 'sub' or 'one'
      scope = "sub"
    }
  }
}
  ```

Above Filters are used based on below properties
```sh
# Pravin Bhagade, users, hadoop, adsre.com
dn: CN=Pravin Bhagade,OU=users,OU=hadoop,DC=adsre,DC=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Pravin Bhagade
sn: Bhagade
givenName: Pravin
instanceType: 4
whenCreated: 20230522161106.0Z
whenChanged: 20230522161106.0Z
displayName: Pravin Bhagade
uSNCreated: 4083
name: Pravin Bhagade
objectGUID:: cGp99nJAnU+dCikwmFtnpA==
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
lastLogon: 0
primaryGroupID: 513
objectSid:: AQUAAAAAAAUVAAAAREN/6ZIYRb7TT457UQQAAA==
accountExpires: 9223372036854775807
logonCount: 0
sAMAccountName: pb203481
sAMAccountType: 805306368
userPrincipalName: pb203481@adsre.com
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=adsre,DC=com
pwdLastSet: 133292454660272970
userAccountControl: 512
uSNChanged: 4085
memberOf: CN=group1,OU=groups,OU=hadoop,DC=adsre,DC=com
memberOf: CN=group2,OU=groups,OU=hadoop,DC=adsre,DC=com
distinguishedName: CN=Pravin Bhagade,OU=users,OU=hadoop,DC=adsre,DC=com

# group2, groups, hadoop, adsre.com
dn: CN=group2,OU=groups,OU=hadoop,DC=adsre,DC=com
objectClass: top
objectClass: group
cn: group2
instanceType: 4
whenCreated: 20230522161141.0Z
uSNCreated: 4087
name: group2
objectGUID:: ZnT2EjoAR0S1P+M1rT/qZQ==
objectSid:: AQUAAAAAAAUVAAAAREN/6ZIYRb7TT457UwQAAA==
sAMAccountName: group2
sAMAccountType: 268435456
groupType: -2147483646
objectCategory: CN=Group,CN=Schema,CN=Configuration,DC=adsre,DC=com
member: CN=Pravin Bhagade,OU=users,OU=hadoop,DC=adsre,DC=com
whenChanged: 20230522161148.0Z
uSNChanged: 4089
distinguishedName: CN=group2,OU=groups,OU=hadoop,DC=adsre,DC=com
```

## 10. Error: kinit: Resource temporarily unavailable while getting initial credentials

1. Review the container logs of 'ad-fsanalyticsv2-connector_default' by executing the following command:

`$ docker logs -f ad-fsanalyticsv2-connector_default &`

`$ accelo admin fsa load`

 
2. If you encounter the following error in the 'ad-fsanalyticsv2-connector_default' container logs:
```
kinit: Resource temporarily unavailable while getting initial credentials
```

3. Access the 'ad-fsanalyticsv2-connector' container by logging in with the following command:

`$ docker exec -it ad-fsanalyticsv2-connector_default sh`

Then, navigate to the following path:

`# cat work/<CLUSTER_NAME>/fsanalytics/kinit_fsimage.sh`

Check if you can successfully run the 'kinit' command. For example:

`$ kinit -kt /krb/security/kerberos.keytab hdfs-hdp314@ADSRE.COM`

If you encounter the following error:
```
kinit: Resource temporarily unavailable while getting initial credentials
```
Verify the contents of the 'krb5.conf' file:

`# cat /krb/security/krb5.conf`

Ensure that you can ping the KDC host. If not, update the entry to use the full FQDN if the current entry is a short name.

**Note:**

* Update the hostnames of the Cluster nodes in the '/etc/hosts' file of the Pulse server.
* Alternatively, you can mount '/etc/resolv.conf' on the 'ad-fsanalyticsv2-connector_default' container.

## 11. ERROR c.a.p.fsanalytics.FsImageService - updating fsimage failed java.io.IOException: listener timeout after waiting for [30000] ms

`$ accelo admin makeconfig ad-fsanalyticsv2-connector`

`vim /opt/pulse/acceldata/config/docker/addons/ad-fsanalyticsv2-connector.yml`

# Add under the Environment section
```
    - ES_CLIENT_SOCKET_TIMEOUT_SECS=120
    - ES_CLIENT_CONNECT_TIMEOUT_SECS=120
    - ES_CLIENT_MAX_RETRY_TIMEOUT_SECS=120
```
`$ accelo restart ad-fsanalyticsv2-connector`

wait for 1 min.

`$ accelo admin fsa load`

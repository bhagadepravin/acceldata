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
10. [Error: kinit: Resource temporarily unavailable while getting initial credentials](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#10-error-kinit-resource-temporarily-unavailable-while-getting-initial-credentials)
11. [ERROR c.a.p.fsanalytics.FsImageService - updating fsimage failed java.io.IOException: listener timeout after waiting for [30000] ms](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#11-error-capfsanalyticsfsimageservice---updating-fsimage-failed-javaioioexception-listener-timeout-after-waiting-for-30000-ms)
12. [ERROR c.a.p.f.elasticsearch.EsWriter - Failed to execute bulk java.net.SocketTimeoutException: null](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#12-error-capfelasticsearcheswriter---failed-to-execute-bulk-javanetsockettimeoutexception-null)
13. [Check Tez Query Dashboard Data missing](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#13-check-tez-query-dashboard-data-missing)
14. [MongoDB shell](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#14-mongodb-shell)
15. [ElasticSearch Commands Cheat Sheet](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#15-elasticsearch-commands-cheat-sheet)
16. [Incomplete Details in Spark Application Page](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#16-incomplete-details-in-spark-application-page)
17. [Increase Shard limit](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#17-increase-shard-limit)
18. [NATS cli](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#18-nats-cli)
19. [Increase NATS storage limit (Default 500GB)](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#19-increase-nats-storage-limit-default-500gb)
20. [NATS local storage cleanup](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#20-nats-local-storage-cleanup)

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
curl -u pulse:data@ops -X GET http://localhost:19013/_cat/indices

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
$ docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
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

Login into Pulse server:

1. Execute the following command to generate the configuration for 'ad-fsanalyticsv2-connector':

`$ accelo admin makeconfig ad-fsanalyticsv2-connector`

2. Open the 'ad-fsanalyticsv2-connector.yml' file using a text editor:
`vim /opt/pulse/acceldata/config/docker/addons/ad-fsanalyticsv2-connector.yml`

3. Add the following lines under the 'Environment' section:
```
    - ES_CLIENT_SOCKET_TIMEOUT_SECS=120
    - ES_CLIENT_CONNECT_TIMEOUT_SECS=120
    - ES_CLIENT_MAX_RETRY_TIMEOUT_SECS=120
```
4. Restart the 'ad-fsanalyticsv2-connector' service:
`$ accelo restart ad-fsanalyticsv2-connector`

5. Wait for approximately 1 minute to allow the service to restart properly.

6. Execute below cmd to load fsimage and verify the logs.
`$ accelo admin fsa load`

## 12. ERROR c.a.p.f.elasticsearch.EsWriter - Failed to execute bulk java.net.SocketTimeoutException: null

1. If you encounter the following error in the 'ad-elastic_default' container logs:
```
ERROR c.a.p.f.elasticsearch.EsWriter - Failed to execute bulk java.net.SocketTimeoutException: null
```

2. Login into Pulse Server:

3. Modify JVM memory of Elastic Search

3. To modify the JVM memory of Elastic container, create ad-logsearch.yml by running below command:

$ accelo admin makeconfig ad-logsearch

4. Open the 'ad-logsearch.yml' file using a text editor:

v`im /opt/pulse/acceldata/config/docker/addons/ad-logsearch.yml`

5. Add property ES_JAVA_OPTS=-Xmx<VALUE>g -Xms<VALUE>g under ad-elastic environment section, save the file and restart ad-elastic container

Example:
Add under the Environment section
ad-elastic:
```
  - ES_JAVA_OPTS=-Xmx32g -Xms32g
```
6. Save the file and restart the 'ad-elastic' container:

`$ accelo restart ad-elastic `


7. Modify JVM memory of Logstash

8 .To modify the JVM memory of Logstash container, create ad-logsearch.yml by running below command:

`$ accelo admin makeconfig ad-logsearch`

9. Add property LS_JAVA_OPTS=-Xmx<VALUE>g -Xms<VALUE>g under ad-logstash environment section, save the file and restart ad-logstash container
  
10. Open the 'ad-logsearch.yml' file using a text editor:

vim /opt/pulse/acceldata/config/docker/addons/ad-logsearch.yml


Example:
Add under the Environment section
ad-logstash:
```
  -  LS_JAVA_OPTS=-Xmx32g -Xms32g
```
Save it:

11. Restart the 'ad-logstash' container:
`$ accelo restart ad-logstash`


## 13. Check Tez Query Dashboard Data missing.

- Check ad-connector logs
- Check in Backend if we see data.

Login into Pulse Server and into the Mongo Database: 
```
$ docker exec -it ad-db_default sh

> mongo mongodb://accel:PASSWORD@localhost:27017/admin

> show databases;
- Select the rtcl3 cluster:

Example:
> use hdp314_zeus;
switched to db hdp314_zeus


db.yarn_tez_queries.count()
db.yarn_tez_queries_details.count()
db.yarn_yarnapps.count()
```
and share the output , having Data "yarn_tez_queries" meaning in Database we have yarn_tez_queries related data and its just not showing in WebUI.
yarn_yarnapps is for Yarn application explorer, for which we already see Data in WebUI.

if you see some counts in "db.yarn_tez_queries.count()" Lets get the first and last record from the tables.

- To query the first record from the "yarn_tez_queries" collection, you can use the following query:

`> db.yarn_tez_queries.find().sort({_id: 1}).limit(1)`

- To query the last record, you can use the following query:

`> db.yarn_tez_queries.find().sort({_id: -1}).limit(1)`


Example: It would like below, You can share the above console outputs
```
> db.yarn_tez_queries.find().sort({_id: 1}).limit(1)
{ "_id" : "hive_20230714060007_d1814e84-2e90-4562-8a0c-698c3796eaea", "appId" : "application_1688472573118_0238", "callerId" : "hive_20230714060007_d1814e84-2e90-4562-8a0c-698c3796eaea", "dagId" : "dag_1688472573118_0238_1", "queue" : "default", "time" : NumberLong("1689315908093"), "counters" : { "org_apache_tez_common_counters_FileSystemCounter" : { "HDFS_BYTES_WRITTEN" : 11318, "HDFS_BYTES_READ" : 694248208 }, "org_apache_tez_common_counters_TaskCounter" : { "PHYSICAL_MEMORY_BYTES" : NumberLong("27015512064"), "CPU_MILLISECONDS" : 56750 } }, "timeTaken" : 21679, "endTime" : NumberLong("1689294638392"), "hiveAddress" : "10.90.6.94", "join" : [ { "rightTable" : null, "rightCol" : "D_DATE_SK", "leftTable" : null, "resolved" : true, "leftCol" : "CS_SOLD_DATE_SK" }, { "rightTable" : null, "rightCol" : "I_ITEM_SK", "leftTable" : null, "resolved" : true, "leftCol" : "CS_ITEM_SK" }, { "rightTable" : null, "rightCol" : "CD_DEMO_SK", "leftTable" : null, "resolved" : true, "leftCol" : "CS_BILL_CDEMO_SK" }, { "rightTable" : null, "rightCol" : "P_PROMO_SK", "leftTable" : null, "resolved" : true, "leftCol" : "CS_PROMO_SK" } ], "llap" : false, "queryUid" : "8346EC875FBA9AFB20E967AD91906250", "startTime" : NumberLong("1689294607010"), "status" : "SUCCEEDED", "tablesUsed" : [ "ITEM", "CUSTOMER_DEMOGRAPHICS", "DATE_DIM", "CATALOG_SALES", "PROMOTION" ], "uid" : "2BAC3860104A4D9FE6EACCEBCD2627B1", "user" : "hive" }
>
> db.yarn_tez_queries.find().sort({_id: -1}).limit(1)
{ "_id" : "hive_20230714121120_3504965e-002b-4f53-aeb3-4035811b57c6", "appId" : "application_1688472573118_0245", "callerId" : "hive_20230714121120_3504965e-002b-4f53-aeb3-4035811b57c6", "dagId" : "dag_1688472573118_0245_1", "queue" : "default", "time" : NumberLong("1689316961653"), "counters" : { "org_apache_tez_common_counters_FileSystemCounter" : { "HDFS_BYTES_WRITTEN" : 11307, "HDFS_BYTES_READ" : 883244425 }, "org_apache_tez_common_counters_TaskCounter" : { "PHYSICAL_MEMORY_BYTES" : NumberLong("46133149696"), "CPU_MILLISECONDS" : 69870 } }, "timeTaken" : 31463, "endTime" : NumberLong("1689316922302"), "hiveAddress" : "10.90.6.94", "join" : [ { "rightTable" : null, "rightCol" : "D_DATE_SK", "leftTable" : null, "resolved" : true, "leftCol" : "SS_SOLD_DATE_SK" }, { "rightTable" : null, "rightCol" : "I_ITEM_SK", "leftTable" : null, "resolved" : true, "leftCol" : "SS_ITEM_SK" }, { "rightTable" : null, "rightCol" : "CD_DEMO_SK", "leftTable" : null, "resolved" : true, "leftCol" : "SS_CDEMO_SK" }, { "rightTable" : null, "rightCol" : "P_PROMO_SK", "leftTable" : null, "resolved" : true, "leftCol" : "SS_PROMO_SK" } ], "llap" : false, "queryUid" : "5ED0EDDADF7785B1FDEE1448D50BC80F", "startTime" : NumberLong("1689316880090"), "status" : "SUCCEEDED", "tablesUsed" : [ "ITEM", "CUSTOMER_DEMOGRAPHICS", "DATE_DIM", "STORE_SALES", "PROMOTION" ], "uid" : "EE930585A8F4D40E84D486880BF1A30C", "user" : "hive" }
```

Ref: https://www.mongodb.com/docs/manual/tutorial/query-documents/

## 14. MongoDB shell

### Select All Documents in a Collection

To select all documents in the collection, pass an empty document as the query filter parameter to the find method. The query filter parameter determines the select criteria:

Examples:
```mongo
db.yarn_yarnapps.find( {} )
db.yarn_yarnapps.find( {} ).limit(1)
db.yarn_yarnapps.find().sort({_id: 1}).limit(1)


db.yarn_yarnapps.find( { _id: 'application_1700799072737_0008' } )

db.yarn_yarnapps.find( { _id: { $in: [ "application_1700799072737_0008", "application_1701084228193_0003" ] } })

db.impala_query_details.count()
db.impala_query_details.getIndexes()
db.impala_query_details.distinct("resource_pool")
db.impala_query_details.createIndex({resource_pool:1})
db.impala_query_details.createIndex({start_time:1,end_time:1})
db.impala_query_details.createIndex({start_time:-1,end_time:-1})
```


## 15. ElasticSearch Commands Cheat Sheet

Check out the [Elasticsearch Commands Cheat Sheet](https://www.bmc.com/blogs/elasticsearch-commands/).

### list all indexes
```bash
curl -X GET 'http://localhost:19013/_cat/indices?v'
```


### list all docs in index
```
curl -X GET 'http://localhost:19013/sample/_search'

curl -X GET 'http://localhost:19013/odp_titan-hdfs-audit-2023.11.28/_search'
```

### query using URL parameters
```
Here we use Lucene query format to write q=school:Harvard.

curl -X GET http://localhost:19013/samples/_search?q=school:Harvard

curl -X GET http://localhost:19013/samples/_search?q=allowed:false
```
### In JSON format 
```
yum install jq -y 

curl -X GET 'http://localhost:19013/odp_titan-logs-syslog-info-2023.11.28/_search' | jq


curl -X GET http://localhost:19013/odp_titan-logs-syslog-info-2023.11.28/_search?q=offset:36492307

curl -X GET http://localhost:19013/odp_titan-logs-syslog-info-2023.11.28/_search?q=offset:36492307  | jq


curl -X GET --header 'Content-Type: application/json' http://localhost:19013/odp_titan-logs-syslog-info-2023.11.28/_search -d '{
"query" : {
"match" : { "offset": "36492307" }
}
}'
```
### Show cluster health
```
curl -H 'Content-Type: application/json' -X GET http://localhost:19013/_cluster/health?pretty
```

## 16. Incomplete Details in Spark Application Page

The Spark application page lacks crucial information, specifically related to configuration and wastage. The Spark configuration details are obtained from the spark.eventLog.dir property within the cluster, with the default setting being spark.eventLog.dir=hdfs:///spark2-history/.

To ensure data availability for Pulse, check the HDFS location (/spark2-history/) and verify that the application file contains the necessary data. Running the command `$ hdfs dfs -ls /spark2-history/` should provide insights into the data presence.

Additionally, gather container logs by executing a sample job:

```bash
/usr/odp/current/spark2-client/bin/spark-sql --master yarn --num-executors 3 --executor-memory 512m --executor-cores 1 --driver-memory 512m --conf spark.sql.shuffle.partitions=5 --conf spark.sql.autoBroadcastJoinThreshold=-1 --conf spark.sql.execution.arrow.enabled=true --conf spark.sql.parquet.writeLegacyFormat=false <<EOF
SELECT 'Hello, World!' as greeting
EOF
```

Collect logs from various Docker containers:

```bash
docker logs ad-streaming_default > /tmp/ad-streaming_default_feb.log
docker logs ad-connectors_default > /tmp/ad-connectors_default_feb.log
docker logs ad-sparkstats_default > /tmp/ad-sparkstats_default_feb.log

tar -cvzf spark-logs-pulse.tar.gz /tmp/ad-streaming_default_feb.log /tmp/ad-connectors_default_feb.log /tmp/ad-sparkstats_default_feb.log
```

Attach the file `spark-logs-pulse.tar.gz` and review the logs for any exceptions. Ensure that ad-sparkstats_default logs successful completion of the application. If not, verify the SparkStats URL in the configuration under `$AcceloHome/config`.

Check MongoDB for relevant information:

```bash
docker exec -it ad-db_default mongo mongodb://accel:password@localhost:27017/admin --eval "db.getSiblingDB('acceldata').monitor_groups.find({}).projection({}).sort({_id: -1}).limit(100)"
```

Review the MongoDB configuration.

## 17. Increase Shard limit
```
open;","error.stack_trace":"org.elasticsearch.common.ValidationException: Validation Failed: 1: this action would add [2] shards, but this cluster currently has [1000]/[1000] maximum normal shards open

the ad-elastic was not working fine due to its shards limit being reached. We increased the shards limit to 3000 using the below command on pulse server that is hosting pulse ad-elastic service:

curl -k -XPUT http://localhost:19013/_cluster/settings -H 'Content-type: application/json' --data-binary $'{"persistent":{"cluster.max_shards_per_node":3000}}'
```

## 18. NATS cli
https://github.com/nats-io/natscli

##### Installation from the shell
The following script will install the latest version of the nats cli on Linux and OS X:

```bash
curl -sf https://binaries.nats.dev/nats-io/natscli/nats@latest | sh
```

```bash
nats context add nats --server localhost:19009 --description "NATS ODP Server" --select
nats context ls
nats stream ls

nats str info hive_queries_events_lotr
nats str edit hive_queries_events_lotr --max-msgs=100000
```

## 19. Increase NATS storage limit (Default 500GB)

Login into Pulse server:

Update value for max_file in `$AcceloHome/config/db/nats-server.conf`

- Increase size from 500G to 700G

`vi $AcceloHome/config/db/nats-server.conf`
- From : 500G to 700G

- Once you edit this file, be sure to restart ad-events

`accelo restart ad-events`

`docker logs -f ad-events_default`

## 20. NATS local storage cleanup

- Check the size of NATS dir.

```bash
du -sch $AcceloHome/data/nats
du -sch $AcceloHome/data/nats/*/*/*

#Delete the dir which is consuming more data and restart ad-events
accelo restart ad-events
```


## wildcard
```
$ curl -X PUT "http://localhost:19013/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"action.destructive_requires_name":false}}'
```

# Managing Applications with `finalStatus` as `UNDEFINED` in MongoDB

This document provides guidance on finding and deleting all application documents in the `yarn_yarnapps` collection where `finalStatus` is set to `UNDEFINED`.

## 1. Finding Application IDs with `finalStatus` as `UNDEFINED`

To retrieve the application IDs for all documents where `finalStatus` is set to `UNDEFINED`, use the following MongoDB query:

```javascript
db.yarn_yarnapps.find({ finalStatus: 'UNDEFINED' }, { _id: 1 })
```

### Explanation
- **Query Filter**: `{ finalStatus: 'UNDEFINED' }` specifies that only documents with a `finalStatus` of `UNDEFINED` should be included in the results.
- **Projection**: `{ _id: 1 }` restricts the output to display only the `_id` field (the application ID) of each matching document.

### Example Output
This query will return a list of application IDs with `finalStatus` as `UNDEFINED`, similar to:

```json
[
  { "_id": "application_1730489651745_0015" },
  { "_id": "application_1730489651745_0016" },
  ...
]
```

## 2. Deleting All Documents with `finalStatus` as `UNDEFINED`

To delete all documents where `finalStatus` is set to `UNDEFINED`, run the following MongoDB command:

```javascript
db.yarn_yarnapps.deleteMany({ finalStatus: 'UNDEFINED' })
```

### Explanation
- **`deleteMany` Method**: This command will delete all documents that match the provided filter.
- **Filter**: `{ finalStatus: 'UNDEFINED' }` ensures that only documents with `finalStatus` set to `UNDEFINED` are deleted.

> **Warning**: This operation is **irreversible** and will permanently delete all matching records. Ensure you have a backup of your data if needed, especially in a production environment.

## Verification

After deletion, you can confirm that all documents with `finalStatus` as `UNDEFINED` have been removed by running:

```javascript
db.yarn_yarnapps.find({ finalStatus: 'UNDEFINED' })
```

If the command returns an empty result set, the deletion was successful.

## Summary

- **Find Application IDs**: `db.yarn_yarnapps.find({ finalStatus: 'UNDEFINED' }, { _id: 1 })`
- **Delete Documents**: `db.yarn_yarnapps.deleteMany({ finalStatus: 'UNDEFINED' })`

This process allows for efficient identification and cleanup of documents with an undefined final status in the `yarn_yarnapps` collection.

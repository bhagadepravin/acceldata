# 1. Pulse File Explorer / ad-fsanalitics container issue

```bash
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<title>Error 403 Only Namenode, Secondary Namenode, and administrators may access this servlet</title>
</head>
<body><h2>HTTP ERROR 403</h2>
<p>Problem accessing /imagetransfer. Reason:
<pre>    Only Namenode, Secondary Namenode, and administrators may access this servlet</pre></p><hr /><i><small>Powered by Jetty://</small></i><br/>
```

--> hdfs headless user is not able to download hdfs fsimage

We need to get the HDFS nn service principal from HDFS active namenode.

Get /etc/security/keytab/nn.service.keytab
Copy it on Pulse Server node.

Goto AcceloHome dir.
cd $AcceloHome

cd work/<CLUSTER_NAME>/fsanalytics/
We need to update below two script with nn service principal rather an hdfs headless principal
Example: here I am using Namenode serivice principal as "nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM"
In customer case:

$ klist -kt /etc/security/keytab/nn.service.keytab

update_fsimage.sh
kinit_fsimage.sh

```bash
cat kinit_fsimage.sh
#!/bin/bash

kinit -kt /krb/security/kerberos.keytab nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM
IsKerberosEnabled=1
```

```bash
update_fsimage.sh

  /usr/bin/gurl -X GET -u "hdfs:" -k -kt /krb/security/kerberos.keytab -kp nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM -o /etc/fsanalytics/$1/fsimage -l "http://hdp314-lab2.iti.acceldata.dev:50070/imagetransfer?getimage=1&txid=latest"
```

Next step:

Navigate to the  ad-fsanalyticsv2-connector.yml file located in the <$AcceloHome>/config/docker/addons directory

If not present, Generate the ad-fsanalyticsv2-connector.yml configuration file by executing the command
`$ accelo admin makeconfig ad-fsanalyticsv2-connector`

Update the new nn.service.keytab to ad-fsanalyticsv2-connector container, we need to add mount point for keytab.

vi ad-fsanalyticsv2-connector.yml

* Add new mount under volumes: sections
* You can copy the nanenode serice keytab under below dir.

cp nn.service.keytab $AcceloHome/config/krb/security

how that mount point will looks below, replace the actual acceloHome path
`- $AcceloHome/config/krb/security:/krb/security/kerberos.keytab`


Few cmds to troubeshoot
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

# Any socket timeout related error
add these in ad-fsanalyticsv2-connector file config/docker/addons folder
ES_CLIENT_SOCKET_TIMEOUT_SECS=120
ES_CLIENT_CONNECT_TIMEOUT_SECS=120
ES_CLIENT_MAX_RETRY_TIMEOUT_SECS=120
```




<p align="center">
  <a href="https://www.acceldata.io">
    <img alt="Jamify" src="https://user-images.githubusercontent.com/28974904/213919727-b58089c7-b9bf-4650-af10-89cda5bb41b7.jpeg" />
  </a>
</p>
<h1 align="center">
   Acceldata <br/>
</h1>



1. [Pulse File Explorer / ad-fsanalitics container issue](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#1-pulse-file-explorer--ad-fsanalitics-container-issue)
2. [Steps to download latest tar docker image, load , replace with old image](https://github.com/bhagadepravin/acceldata/blob/main/known-issue/pulse-issues.md#2-steps-to-download-latest-tar-docker-image-load--replace-with-old-image)

## 1. Pulse File Explorer / ad-fsanalitics container issue

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

1. Get the `nn.service.keytab` file from the HDFS active namenode's `/etc/security/keytab/` directory
2. Copy the keytab file to the Pulse Server node
3. Go to the AcceloHome directory:
```
$ cd $AcceloHome
$ cd work/<CLUSTER_NAME>/fsanalytics/
```
4. Update the following two scripts with the nn service principal:

Example: Using the Namenode service principal `nn/hdp314-lab1.iti.acceldata.dev@ADSRE.COM`
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

Note: In customer case use the below command to check the Namenode service principal
```
$ klist -kt /etc/security/keytab/nn.service.keytab
```
5. Navigate to the `ad-fsanalyticsv2-connector.yml` file located in the `<$AcceloHome>/config/docker/addons` directory.

6. If not present, Generate the `ad-fsanalyticsv2-connector.yml` configuration file by executing the command
`$ accelo admin makeconfig ad-fsanalyticsv2-connector`

7. Update the new `nn.service.keytab` to `ad-fsanalyticsv2-connector` container, we need to add mount point for keytab.

`$ vi ad-fsanalyticsv2-connector.yml`

8. Add a new mount under the **volumes:** section. You can copy the nanenode service keytab under the directory:

`$ cp nn.service.keytab $AcceloHome/config/krb/security`

The mount point should look like this (replace the actual `$AcceloHome` path):
`- $AcceloHome/config/krb/security:/krb/security/kerberos.keytab`

9. Restart ad-fsanalyticsv2-connector and Load the fsimage again
```
accelo restart ad-fsanalyticsv2-connector
accelo admin fsa load
```

Once these steps are completed, the HDFS fsimage should be able to be downloaded without any 403 errors.

10. Troubleshoot:
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


## 2. Steps to download latest tar docker image, load , replace with old image 

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

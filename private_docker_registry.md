# Deploy a private docker registry in air-gapped environment

### Pre-defined environment

- Internet availabe host: **localhost**
- Air-gaped host: **master01.airgapped.org**

## Prepare required Docker environments


### Pre-request

- You have to use the same linux distribution with your air-gaped host, which is master01.airgapped.org, in this artical we adopt CentOS 7 as host system.
- You’d have to obtain a PURE linux environment which HAVE Internet access without any post-installed packages as was installed in master01.airgapped.org. Otherwise you may encounter failed dependencies for docker in the master01.airgapped.org.
- We assume that you have a PURE Internet access availabe host named localhost.

### 1. Download and install the required packages for Docker

- On the **localhost** , run following commands:
```bash
sudo yum -y -q install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
mkdir ~/rpms
sudo yum update && yum install -y --downloadonly  --downloaddir=${HOME}/rpms docker-ce fuse-overlayfs slirp4netns fuse3-libs
ssh user@master01.airgapped.org mkdir packages
#You can verify the outcome by type
ssh user@master01.airgapped.org "pwd && ls"
scp ${HOME}/rpms/* user@master01.airgapped.org:~/packages
```
- On the **master01.airgapped.org** , run following commands to install Docker environment
```bash
cd ~/packages
sudo rpm -ivh *
```
If you encoutner missing depandency error like
copy the pacakge and for conflicts remove the package or download it accordingly

```bash
error: Failed dependencies:
	fuse-overlayfs >= 0.7 is needed by docker-ce-rootless-extras-0:20.10.17-3.el7.x86_64
	slirp4netns >= 0.4 is needed by docker-ce-rootless-extras-0:20.10.17-3.el7.x86_64

error: Failed dependencies:
	libfuse3.so.3()(64bit) is needed by fuse-overlayfs-0.7.2-6.el7_8.x86_64
	libfuse3.so.3(FUSE_3.0)(64bit) is needed by fuse-overlayfs-0.7.2-6.el7_8.x86_64
	libfuse3.so.3(FUSE_3.2)(64bit) is needed by fuse-overlayfs-0.7.2-6.el7_8.x86_64
```

On the **localhost** you can run
yum remove docker-ce-cli
```
sudo yum update && yum reinstall -y --downloadonly  --downloaddir=${HOME}/rpms fuse-overlayfs slirp4netns fuse3-libs
```
Make sure you add dependency pacakges
And redo the scp command for the missing rpms.

- And redo the scp command for the missing rpms.

### 2. Setup Docker environment and Shoot!

- On the **master01.airgapped.org** , following the procedure defined in Manage Docker as a non-root user to add docker user group.
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

```
You have to re-login to make current $USER group affect.
```
- On the **master01.airgapped.org** , disable SeLinux in order to allow docker container access the host path file.
  
```bash
sudo setenforce 0
sudo sed 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config > /etc/selinux/config
```

Verify the whether selinux is disabled:

```bash
$ getenforce
Permissive
```
- On the master01.airgapped.org , enable and start the docker deamon.

```bash
sudo systemctl enable docker && sudo systemctl start docker
```

- On the **master01.airgapped.org** , check whether docker start successfully.
```
systemctl status docker
```

## Setup private registry service

### Pre-request

- You have pulled the newset docker registry image from docker.io and export it to the tar archive.
```bash
   docker pull registry \
   && docker save docker.io/registry:latest -o docker-io.registry.tar
```

- You have to import the registry image to the master01.airgapped.org docker image repo cache
```bash
 docker load -i docker-io.registry.tar
```

On **master01.airgapped.org**

### 1. Create HTTPS certificates required for docker private registry

This procedure follows the example on Openssl certificate creation on k8s official document

On **master01.airgapped.org** ：

- Prepare cert storage directory
```bash
   sudo mkdir /usr/lib/certs -p
   pushd /usr/lib/certs
```
- Generate CA key file
```bash
sudo openssl genrsa -out ca.key 2048
```
- Generate CA certificate file
```bash
sudo openssl req -x509 -new -nodes -key ca.key -subj "/CN=${MASTER_IP}" -days 10000 -out ca.crt
```

- You can replace **${MASTER_IP}** with your actual or persuade CA server ip address like
```bash
 sudo openssl req -x509 -new -nodes -key ca.key -subj "/CN=8.8.8.8" -days 10000 -out ca.crt
```

- Generate docker docker registry server key file
```bash
sudo openssl genrsa -out private-registry-server.key 2048
```

- Create a config file for generating a Certificate Signing Request (CSR) for docker registry server

```bash

cat > /tmp/private-registry-server.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = cn #replace with actual info
ST = Tianjin #replace with actual info
L = Tianjin #replace with actual info
O = Air Gaped Company #replace with actual info
OU = Air Gaped team #replace with actual info
CN = master01.airgapped.org  #replace with actual registry server name

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = master01.airgapped.org #replace with alternative dns resolve name
DNS.2 = registry.airgapped.org #replace with alternative dns resolve name
IP.1 = 192.168.122.163 #replace with actuel ip for the registry server

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names

EOF
sudo scp /tmp/private-registry-server.conf ./
```

- Generate the certificate signing request based on the config file for docker registry server
```bash
sudo openssl req -new -key  private-registry-server.key \
-out private-registry-server.csr \
-config private-registry-server.conf
```
- Sign the registry server certificate with CA cert and docker registry server CSR file
```
sudo openssl x509 -req -in private-registry-server.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out private-registry-server.crt -days 10000 \
-extensions v3_ext -extfile private-registry-server.conf
```
- Verify the final cert for registry server
```
openssl x509  -noout -text -in private-registry-server.crt
```

### 2. Start private registry

- Copy the CA certificate to docker’s certs directory to avoid insecur repository error, the directory which certs resides in must have the same hostname with the private registry domain name.
```bash
sudo mkdir /etc/docker/certs.d/registry.airgapped.org -p
sudo cp /usr/lib/certs/ca.crt /etc/docker/certs.d/registry.airgapped.org
```
- Run registry container with preset certs and port config
```bash
sudo mkdir /mnt/docker_images
docker run -d --restart=always -v /mnt/docker_images:/var/lib/registry \
   -v /usr/lib/certs:/cert \
   -e REGISTRY_HTTP_TLS_CERTIFICATE=/cert/private-registry-server.crt \
   -e REGISTRY_HTTP_TLS_KEY=/cert/private-registry-server.key \
   -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
   -p 443:443 --name local-registry registry
```
- Verify private registry successfully started and listen on assigned port
```bash
 docker logs local-registry
```
- You should see the following output like,with listening on [::]:443
- 
 ``` bash
  time=”2017-12-18T12:57:53Z” level=warning msg=”No HTTP secret provided - generated random secret. This may cause problems with uploads if multiple registries are behind a load-balancer. To provide a shared secret, fill in http.secret in the configuration file or set the REGISTRY_HTTP_SECRET environment variable.” go.version=go1.7.6 instance.id=df382424-0e5d-49ad-b758-2b7b3e92d32f version=v2.6.2 time=”2017-12-18T12:57:53Z” level=info msg=”redis not configured” go.version=go1.7.6 instance.id=df382424-0e5d-49ad-b758-2b7b3e92d32f version=v2.6.2 time=”2017-12-18T12:57:53Z” level=info msg=”Starting upload purge in 37m0s” go.version=go1.7.6 instance.id=df382424-0e5d-49ad-b758-2b7b3e92d32f version=v2.6.2 time=”2017-12-18T12:57:54Z” level=info msg=”using inmemory blob descriptor cache” go.version=go1.7.6 instance.id=df382424-0e5d-49ad-b758-2b7b3e92d32f version=v2.6.2 time=”2017-12-18T12:57:54Z” level=info msg=”listening on [::]:443, tls” go.version=go1.7.6 instance.id=df382424-0e5d-49ad-b758-2b7b3e92d32f version=v2.6.2
```  
- Append registry.airgapped.org domain to /etc/hosts, as dedicate domain for registry service
  
  If every thing is ok, you shall see the result by verifing the registry v2 API

### 3. Push your first image to private registry and verify

On **master01.airgapped.org**, At this point, you have:

- one available private registry which is host on **master01.airgapped.org** and with a dedicate domain name **registry.airgapped.org** with TLS enabled, listening on port 443.
- one local image named docker.io/registry:latest cached on **master01.airgapped.org** , as:
Now you have to:
```bash
$ docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
docker.io/registry               latest              177391bcf802        2 weeks ago 
```
- Tag cached image with new registry path which leads to registry.airgapped.org
```bash
 $ docker tag docker.io/registry:latest registry.airgapped.org/registry:latest
 $ docker images
 REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
 registry.airgapped.org/registry   latest              177391bcf802        2 weeks ago         33.26 MB
 docker.io/registry               latest              177391bcf802        2 weeks ago  
```
- Push newly taged image to **registry.airgapped.org**
```bash
 docker push registry.airgapped.org/registry
```
- Remove cached image on local docker, newly tag **registry.airgapped.org/registry:latest**
```bash
 docker rmi registry.airgapped.org/registry:latest
 $ docker images
 REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
 docker.io/registry   latest              177391bcf802        2 weeks ago         33.26 MB
```
- Pull image registry from registry.airgapped.org

```bash
$ docker pull registry.airgapped.org/registry
 Using default tag: latest
 Trying to pull repository registry.airgapped.org/registry ...
 latest: Pulling from registry.airgapped.org/registry
 Digest: sha256:e82c444f6275eaca07889d471943668ac17fd03ea8d863289a54c199ed216332

 $ docker images
 REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
 docker.io/registry               latest              177391bcf802        2 weeks ago         33.26 MB
 registry.airgapped.org/registry   latest              177391bcf802        2 weeks ago         33.26 MB
```

Now, you have a working and verified private registry！

For securer docker access, you shall follow the instruction list on Restricting access.

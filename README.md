## Acceldata

##### K9s on Centos 7

```bash
yum install epel-release -y
yum install -y snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install k9s
```

#### Enable metrics for K8
```
yum install -y -q git
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git
kubectl create -f kubernetes-metrics-server/
```
#### Portainer WebUi for Docker
```
# Install
docker run  --name portainer -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer

# Uninstall
docker rm -vf portainer
docker volume rm -f portainer_data
```

#### SQL Developer Downloads
```
https://www.oracle.com/java/technologies/downloads/#java8-mac
https://www.oracle.com/tools/downloads/sqldev-downloads.html
```

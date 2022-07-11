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

or:

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
#### Portainer WebUi for Docker
```bash
# Install
docker run  --name portainer -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer:latest

# Uninstall
docker rm -vf portainer
docker volume rm -f portainer_data
```

#### SQL Developer Downloads
```
https://www.oracle.com/java/technologies/downloads/#java8-mac
https://www.oracle.com/tools/downloads/sqldev-downloads.html
```

#### Install Helm
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update # Make sure we get the latest list of charts
helm list
```

#### Pulse reset admin password
```bash
accelo admin encrypt  | tee ~/passwd.log
grep ENCRYPTED ~/passwd.log | awk -F " " '{print $2}'
PASSWORD=`grep ENCRYPTED ~/test.log | awk -F " " '{print $2}'`
cd $AcceloHome/config
sed -i 's/8ulzObak4uWP3dJWktqTuA==/$PASSWORD/g' acceldata_*.conf
accelo admin database push-config -a
```

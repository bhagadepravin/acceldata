## Acceldata

##### LVM resize
```
yum -y install cloud-utils-growpart && growpart /dev/sda 2; pvresize /dev/sda2; lvextend -l+100%FREE /dev/centos/root; xfs_growfs /dev/centos/root;lsblk

# for rocky linux 8 lab node
yum -y install cloud-utils-growpart && growpart /dev/sda 3; pvresize /dev/sda3; lvextend -l+100%FREE /dev/mapper/rl-root; xfs_growfs /dev/mapper/rl-root;lsblk

sudo apt-get update
sudo apt-get install cloud-guest-utils cloud-utils  xfsprogs -y
sudo growpart /dev/sda 5
sudo pvresize /dev/sda5
sudo lvextend -l+100%FREE /dev/mapper/vgubuntu-root
sudo resize2fs /dev/mapper/vgubuntu-root
sudo lsblk


```

##### K9s on Centos 7

```bash
yum install epel-release -y
yum install -y snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
su -
snap install k9s


+++++
curl -sS https://webinstall.dev/k9s | bash
source ~/.config/envman/PATH.env
echo "source ~/.config/envman/PATH.env" >> ~/.bash_profile
echo "source ~/.config/envman/PATH.env" >> ~/.bashrc
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
PASSWORD=`grep ENCRYPTED ~/test.log | awk -F " " '{print $2}'`
cd $AcceloHome/config
sed -i 's/8ulzObak4uWP3dJWktqTuA==/$PASSWORD/g' acceldata_*.conf
accelo admin database push-config -a
```

##### custom Spark default config
```
spark.driver.memoryOverhead 1024
spark.network.timeout 10000000
spark.eventLog.enabled true
spark.executor.extraJavaOptions -XX:+UseG1GC -XX:+PrintFlagsFinal -XX:+PrintReferenceGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintAdaptiveSizePolicy -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:InitiatingHeapOccupancyPercent=85 -XX:ConcGCThread=20
spark.executor.heartbeatInterval 1000000
spark.executor.memoryOverhead 1024
spark.history.fs.cleaner.enabled true
spark.history.fs.cleaner.interval 1h
spark.history.fs.cleaner.maxAge 12h
```

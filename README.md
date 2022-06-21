## Acceldata

##### K9s on Centos 7

```bash
yum install epel-release -y
yum install -y snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install k9s
```

# Enable metrics for K8
```
yum install -y -q git
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git
kubectl create -f kubernetes-metrics-server/
```

## Acceldata

##### K9s on Centos 7

```bash
yum install epel-release -y
yum install -y snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install k9s
```

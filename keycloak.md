## Setup Keycloak via docker

Before you start
Make sure you have Docker installed.

```bash
yum install yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y
# or
# yum install docker -y

systemctl start docker
systemctl status docker
systemctl enable docker
```

```bash
#!/bin/bash

which docker &&  docker --version | grep "Docker version"

if [ $? -eq 0 ]
then
         echo "docker existing"  
    else
         echo "install docker"
         sudo yum -y install yum-utils device-mapper-persistent-data lvm2
         yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
         yum clean all && yum update all  && yum install -y wget git vim docker-ce iptables docker-ce-cli containerd.io
         systemctl enable docker
         systemctl restart docker
         docker version
    fi
```

sysctl -w net.ipv4.ip_forward=1
sudo sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
sudo sysctl -p /etc/sysctl.conf


Start Keycloak
From a terminal start Keycloak with the following command:
```bash
docker run -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -e DB_VENDOR=H2 -p 8080:8080 --name keycloak jboss/keycloak
```
Wait until you see 

```
12:40:52,608 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://127.0.0.1:9990
```

This will start Keycloak exposed on the local port 8080. It will also create an initial admin user with `username admin` and `password admin`.

Login to the admin console
Go to the `Keycloak Admin Console` http://hostname:8080/auth/admin and login with the username and password you created earlier.

Ref: https://www.keycloak.org/getting-started/getting-started-docker

```
Crtl+C
$ docker start keycloak
```

`Create a new realm`


#### Keycloak - SAML :

-  1.  Create SAML client in keycloak.

-  2.  Sample config

![keycl1](https://github.com/bhagadepravin/knox-workshop/blob/master/jpeg/keycload%20cleint1.png)
![keycl2](https://github.com/bhagadepravin/knox-workshop/blob/master/jpeg/keycload%20client2.png)

-  3.  Create user account under the realm and set password.

-  4.  Get the IDP SSO metadata using keycloak url :

```
# curl -ik https://keycloak-FQDN:port/auth/realms/KeycloakRealmName/protocol/saml/descriptor -o idp.xml

curl -ik -u admin:admin http://pbhagade-boo-1.pbhagade-boo.root.hwx.site:8080/auth/realms/workshop/protocol/saml/descriptor  -o idp.xml
```
-  5.  Copy idp.xml file to the knox host.
`Remove HTTP header from idp.xml file`

-  6.  With the newest version of CM a new Knox configuration has been added, called ***Knox Simplified Topology Management - SSO Authentication Provider***, with the following initial configuration:

**Tip:**
You can also use Knox Admin UI or manually create custom saml topology.

```bash
role=authentication
authentication.name=ShiroProvider
authentication.enabled=false
role=federation
federation.name=pac4j
federation.param.clientName=SAML2Client
federation.param.pac4j.callbackUrl=https://pbhagade-boo-1.pbhagade-boo.root.hwx.site:8443/gateway/knoxsso/api/v1/websso
federation.param.saml.identityProviderMetadataPath=/etc/knox/conf/idp.xml
federation.param.saml.serviceProviderEntityId=Knox-saml-workshop
authentication.param.remove=main.pamRealm
authentication.param.remove=main.pamRealm.service
```

-  7.  Setup any service for SSO authentication and verify the SSO redirection and authentication.

-  8.  Sample config knoxsso.xml 

```xml
<topology>
    <generated>true</generated>
    <gateway>
        <provider>
            <role>webappsec</role>
            <name>WebAppSec</name>
            <enabled>true</enabled>
            <param>
                <name>xframe.options.enabled</name>
                <value>true</value>
            </param>
        </provider>
        <provider>
            <role>authentication</role>
            <name>ShiroProvider</name>
            <enabled>false</enabled>
            <param>
                <name>main.pamRealm</name>
                <value>org.apache.knox.gateway.shirorealm.KnoxPamRealm</value>
            </param>
            <param>
                <name>main.pamRealm.service</name>
                <value>login</value>
            </param>
            <param>
                <name>redirectToUrl</name>
                <value>/${GATEWAY_PATH}/knoxsso/knoxauth/login.html</value>
            </param>
            <param>
                <name>restrictedCookies</name>
                <value>rememberme,WWW-Authenticate</value>
            </param>
            <param>
                <name>sessionTimeout</name>
                <value>30</value>
            </param>
            <param>
                <name>urls./**</name>
                <value>authcBasic</value>
            </param>
        </provider>
        <provider>
            <role>federation</role>
            <name>pac4j</name>
            <enabled>true</enabled>
            <param>
                <name>clientName</name>
                <value>SAML2Client</value>
            </param>
            <param>
                <name>pac4j.callbackUrl</name>
                <value>https://pbhagade-boo-1.pbhagade-boo.root.hwx.site:8443/gateway/knoxsso/api/v1/websso</value>
            </param>
            <param>
                <name>saml.identityProviderMetadataPath</name>
                <value>/etc/knox/conf/idp.xml</value>
            </param>
            <param>
                <name>saml.serviceProviderEntityId</name>
                <value>knox-pravin</value>
            </param>
        </provider>
        <provider>
            <role>identity-assertion</role>
            <name>Default</name>
            <enabled>true</enabled>
        </provider>
    </gateway>

    <service>
        <role>KNOXSSO</role>
        <param>
            <name>knoxsso.token.ttl</name>
            <value>86400000</value>
        </param>
    </service>
    <application>
        <name>knoxauth</name>
    </application>
</topology>
```
**Note**

`(Changes required for properties pac4j.callbackUrl, saml.identityProviderMetadataPath and saml.serviceProviderEntityId)`

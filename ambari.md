
## Ambari Database cleanup
```SQL
mysql

DROP DATABASE IF EXISTS ambari;
CREATE USER 'ambari'@'%' IDENTIFIED BY 'bigdata';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'bigdata';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'ansible.iti.acceldata.dev';
FLUSH PRIVILEGES;
```

```psql
psql

DROP DATABASE IF EXISTS ambari;
CREATE DATABASE ambari;
CREATE USER ambari WITH PASSWORD 'bigdata';
GRANT ALL PRIVILEGES ON DATABASE ambari TO ambari; 
\connect ambari; 
CREATE SCHEMA ambari AUTHORIZATION ambari;
ALTER SCHEMA ambari OWNER TO ambari;
ALTER ROLE ambari SET search_path to 'ambari', 'public';
```

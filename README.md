# phpchain



## Puppet module to install phpchain 2.0

Requires EPEL and puppet modules Apache, MySQL.

Create SSL certs.

```
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/phpchain2.local.lan.key -out /etc/pki/tls/certs/phpchain2.local.lan.crt
```

Web UI

Login into the ui, follow instructions to delete setup files and then create a login user. 
Then we need to disable newuser.php

```
  mv newuser.php{,.off}
```

Restoring from sql backup

If you loose the login then you need to rebuild and restore the db.
Delete existing http and mysql data and config.
Re run this puppet module and restore the db eg.

```
  mysql -u root -p -h localhost phpchain <mysql_backup_phpchain_20150901-194809.sql
```

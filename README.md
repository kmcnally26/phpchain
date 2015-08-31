# phpchain
Puppet module to install phpchain 2.0

Add detail to init.pp
```
  $ssl_hostname                     = 'phpchain2.local.lan',
  $ssl_keypath                      = '/etc/pki/tls/private/phpchain2.local.lan.key',
  $ssl_certpath                     = '/etc/pki/tls/certs/phpchain2.local.lan.crt',
  $phpchain_root                    = '/var/www/html',
  $phpchain_sitename                = 'Lastminute phpChain',
  $mysql_rootpw                     = 'password',
  $mysql_dbHost                     = 'localhost',
  $mysql_dbUsername                 = 'phpchain',
  $mysql_dbPassword                 = 'password',
  $mysql_dbName                     = 'phpchain',
```
Create SSL certs as per above and move to path.
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout phpchain2.local.lan.key -out phpchain2.local.lan.crt
```

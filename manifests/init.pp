class phpchain (

  $ssl_hostname                     = 'phpchain.local.lan'
  $phpchain_sitename                = 'Lastminute phpChain'
  $phpchain_root                    = '/var/www/html'
  $mysql_rootpw                     = 'password'
  $mysql_dbHost                     = 'localhost'
  $mysql_dbUsername                 = 'phpchain'
  $mysql_dbPassword                 = 'password'
  $mysql_dbName                     = 'phpchain'

)  {

  file { '/etc/httpd/conf.d/ssl.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template("${module_name}/ssl.conf.erb"),
  }

  file { "/${phpchain::phpchain_root}/phpchain":
    ensure  => directory,
    recurse => true,
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
  }

  file { "/${phpchain::phpchain_root}/phpchain-2.0.11-beta.tgz":
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    source  => "puppet:///modules/${module_name}/phpchain-2.0.11-beta.tgz"
  }

  exec { "Extract phpchain source code" :
    command => "/bin/tar xzf ${phpchain::phpchain_root}/phpchain-2.0.11-beta.tgz -C ${phpchain::phpchain_root}",
    unless  => "/bin/ls /${phpchain::phpchain_root}/phpchain/config/config.php",
  }

  file { "/${phpchain::phpchain_root}/phpchain/config/config.php":
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    content => template("${module_name}/config.php.erb"),
  }

  service { 'mysqld':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  service { 'httpd':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  package { [ 'httpd',
              'mod_ssl',
              'php',
              'php-mcrypt',
              'php-mysql',
              'mysql-server',
              'mysql',
              'mod_ssl'
              ]:
    ensure => installed,
  }

## Mysql
  file { '/root/.my.cnf':
    owner   => 'root',
    group   => 'root',
    mode    => '640',
    content => template("${module_name}/my.cnf.erb"),
  }

  exec { "Set root account for mysql install" :
    command => "/usr/bin/mysqladmin -e '-u root password ${phpchain::mysql_rootpw};'",
    unless  => "/usr/bin/mysql -e 'use ${phpchain::mysql_dbName};'",  
  }
 
  exec { "Create database ${phpchain::mysql_dbName}" :
    command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${phpchain::mysql_dbName};'",
    unless  => "/usr/bin/mysql -e 'use ${phpchain::mysql_dbName};'",  
  }
 
  exec { "Create database ${phpchain::mysql_dbName}" :
    command => "/usr/bin/mysql -e 'create user ${phpchain::mysql_dbUsername}@${phpchain::mysql_dbHost} identified by ${phpchain::mysql_dbPassword};'",
    unless  => "/usr/bin/mysql -e 'use ${phpchain::mysql_dbName};'",  
  }
 
  exec { "Create database ${phpchain::mysql_dbName}" :
    command => "/usr/bin/mysql -e 'grant all privileges on ${phpchain::mysql_dbName}* to ${phpchain::mysql_dbUsername}@${phpchain::mysql_dbHost};'",
    unless  => "/usr/bin/mysql -e 'use ${phpchain::mysql_dbName};'",  
  }
 

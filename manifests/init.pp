class phpchain (

  $server_name                      = $fqdn,
  $keypath                          = '/etc/pki/tls/private/phpchain.elab.lastminute.com.key',
  $certpath                         = '/etc/pki/tls/certs/phpchain.elab.lastminute.com.crt',
  $phpchain_root                    = '/opt/www/phpchain',
  $phpchain_base                    = '/opt/www',

  $phpchain_sitename                = 'Lastminute phpChain',
  $mysql_rootpw                     = '5CLM1liNRl',
  $mysql_dbHost                     = 'localhost',
  $mysql_dbUsername                 = 'phpchain',
  $mysql_dbPassword                 = '8zomz7uGJ0',
  $mysql_dbName                     = 'phpchain',
  $mysql_backupuser                 = 'MrBackups',
  $mysql_backuppw                   = 'XXaBO7cTI9',

)  {

## Apache setup
class { 'apache': }
  include apache::mod::php
  apache::vhost { $server_name :
    port     => '443',
    docroot  => $phpchain_root,
    ssl      => true,
    ssl_key  => $keypath,
    ssl_cert => $certpath,

}

## Mysql setup
  class { '::mysql::server':
    root_password           => $mysql_rootpw,
    remove_default_accounts => true,
    create_root_my_cnf      => true,
    override_options => { 'mysqld' => { 'max_connections' => '1024', 'bind-address' => "$mysql_dbHost" } }
  }

  mysql::db { $mysql_dbName:
    user     => $mysql_dbUsername,
    password => $mysql_dbPassword,
    host     => $mysql_dbHost,
  }

  mysql_grant { "${mysql_dbUsername}@${mysql_dbHost}/*.*":
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => "${mysql_dbUsername}@${mysql_dbHost}",
  }

  class { '::mysql::backup::mysqldump': 
    backupuser     => $mysql_backupuser,
    backuppassword => $mysql_backuppw,
    backupdir      => '/root/phpchain-mysql-backups', 
    backupdatabases => $mysql_dbName,
    backuprotate    => 7,
  }

## phpChain
  file { $phpchain::phpchain_base :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
  }->

  file { "${phpchain::phpchain_base}/phpchain-2.0.11-beta.tgz":
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    source  => "puppet:///modules/${module_name}/phpchain-2.0.11-beta.tgz"
  }->

  exec { "Extract phpchain source code" :
    command => "/bin/tar xzf ${phpchain::phpchain_base}/phpchain-2.0.11-beta.tgz -C ${phpchain::phpchain_base}",
    unless  => "/bin/ls /${phpchain::phpchain_base}/phpchain-2/config",
  }->

  file { "${phpchain::phpchain_base}/phpchain-2":
    ensure  => directory,
    recurse => true,
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
  }->

## Tar gets extracted as phpchain-2 so symlink
  file { "${phpchain::phpchain_base}/phpchain":
    ensure => link,
    target => "${phpchain::phpchain_base}/phpchain-2",
  }->


  file { "${phpchain::phpchain_base}/phpchain/config/config.php":
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    content => template("${module_name}/config.php.erb"),
  }

  package { [ 'php',
              'php-common',
              'php-mcrypt',
              'php-mysql'
              ]:
    ensure => installed,
  }

}

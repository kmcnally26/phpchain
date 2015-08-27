class phpchain (

  $ssl_hostname                     = 'phpchain.local.lan',
  $phpchain_sitename                = 'Lastminute phpChain',
  $phpchain_root                    = '/var/www/html',
  $mysql_rootpw                     = 'password',
  $mysql_dbHost                     = $ipaddress,
  $mysql_dbUsername                 = 'phpchain',
  $mysql_dbPassword                 = 'password',
  $mysql_dbName                     = 'phpchain',

)  {

## Apache setup
class { 'apache': }
  include apache::mod::php
  apache::vhost { $ssl_hostname :
    port    => '443',
    docroot => $phpchain_root,
    ssl     => true,
  }
#  class { 'apache':
#    default_mods => false,  
#  }  
#  include apache::mod::php  
#  apache::vhost { 'webserver.puppetlabs.com':    
#    port    => '80',    
#   docroot => '/var/www/webserver'  
#  }
#}

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

## phpchain setup - Maybe this should be a git clone etc and get dir structure
  file { "${phpchain::phpchain_root}/phpchain-2.0.11-beta.tgz":
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    source  => "puppet:///modules/${module_name}/phpchain-2.0.11-beta.tgz"
  }->

  exec { "Extract phpchain source code" :
    command => "/bin/tar xzf ${phpchain::phpchain_root}/phpchain-2.0.11-beta.tgz -C ${phpchain::phpchain_root}",
    unless  => "/bin/ls /${phpchain::phpchain_root}/phpchain-2/config",
  }->

  file { "${phpchain::phpchain_root}/phpchain-2":
    ensure  => directory,
    recurse => true,
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
  }->

## Tar gets extracted as phpchain-2 so symlink
  file { "${phpchain::phpchain_root}/phpchain":
    ensure => link,
    target => "${phpchain::phpchain_root}/phpchain-2",
  }->


  file { "${phpchain::phpchain_root}/phpchain-2/config/config.php":
    ensure  => present,
    owner   => 'apache',
    group   => 'apache',
    mode    => '644',
    content => template("${module_name}/config.php.erb"),
  }

  package { [ 'php',
              'php-mcrypt',
              'php-mysql'
              ]:
    ensure => installed,
  }

}

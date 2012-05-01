# Class: mongodb
#
# This class installs MongoDB (stable)
#
# Notes:
#  This class is Ubuntu specific.
#  By Sean Porter Consulting
#
# Actions:
#  - Install MongoDB using a 10gen Ubuntu repository
#  - Manage the MongoDB service
#  - MongoDB can be part of a replica set
#
# Sample Usage:
#  class { mongodb:
#    replSet => "myReplicaSet",
#    ulimit_nofile => 20000,
#  }
#
class mongodb(
  $replSet = $mongodb::params::replSet,
  $ulimit_nofile = $mongodb::params::ulimit_nofile,
  $repository = $mongodb::params::repository,
  $package = $mongodb::params::package
) inherits mongodb::params {
  if !defined(Package["python-software-properties"]) {
    package { "python-software-properties":
      ensure => installed,
    }
  }

  exec { "10gen-apt-repo":
    path => "/bin:/usr/bin",
    command => "echo '${repository}' >> /etc/apt/sources.list",
    unless => "cat /etc/apt/sources.list | grep 10gen",
    require => Package["python-software-properties"],
  }

  exec { "10gen-apt-key":
    path => "/bin:/usr/bin",
    command => "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
    unless => "apt-key list | grep 10gen",
    require => Exec["10gen-apt-repo"],
  }

  exec { "update-apt":
    path => "/bin:/usr/bin",
    command => "apt-get update",
    unless => "ls /usr/bin | grep mongo",
    require => Exec["10gen-apt-key"],
  }

  package { $package:
    ensure => installed,
    require => Exec["update-apt"],
  }
  
  package { 'php-pear':
    ensure => installed,
 #   require => Package["php5"],
  }
  package { 'php5-dev':
    ensure => installed,
 #   require => Package["php5"],
  }
package { 'apache2':
    ensure => installed,
    
  }
package { 'php5':
    ensure => installed,
    require => Package["apache2"],
  }

  package { 'libcurl3-openssl-dev':
    ensure => installed,
    
  }
  package { 'make':
    ensure => installed,
  }
  package { 'unzip':
    ensure => installed,
  }

  service { "mongodb":
    enable => true,
    ensure => running,
    require => Package[$package],
  }

  service { "apache2":
    enable => true,
    ensure => running,
    require => Package["apache2"],
  }
  exec { "install-php-mongo":
    command =>  "pecl install mongo",
    group => root,
    path    => ["/usr/bin", "/usr/sbin"],
    require => [Package["php5-dev"],Package["make"],Package["libcurl3-openssl-dev"]],
  }     
 
  exec { "add_mongo_extension":
   command =>  "sed -i \'/default extension directory./a \\ extension=mongo.so \'  /etc/php5/cli/php.ini",
    path => ["/bin", "/usr/share/doc/"],
   notify => Service["apache2"],
    require => Package["php5"],
  }

  exec {" download_rockmongo":
    command => "wget https://rock-php.googlecode.com/files/${rockmongo_zip}",
    cwd => "/tmp",
    path => ["/usr/bin", "/usr/sbin"],
    require => File["/tmp"],
  }
  
  file {"/tmp":
    ensure => "directory",
  }  
   
  file {["/var/","/var/www/","/var/www/html/",$rockmongo_dir]:
    mode => "0767",
    ensure => "directory",
  }  
  
 exec { "unzip-file":
   command => "unzip   /tmp/${rockmongo_zip}",
   cwd => $rockmongo_dir,
   path => ["/usr/bin", "/usr/sbin"],
   require => [File[$rockmongo_dir],Package["unzip"]],
}

 exec { "createdb-admin-user":
    command => "mongo admin --eval \'db.addUser(${admin}, ${admin})\'",
    path => ["/usr/bin", "/usr/sbin"],
    require => Package[$package],
  }

  file { "/etc/init/mongodb.conf":
    content => template("mongodb/mongodb.conf.erb"),
    mode => "0644",
    notify => Service["mongodb"],
    require => Package[$package],
  }
 

}

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
    require => Package["php"],
  }
  package { 'php5-dev':
    ensure => installed,
    require => Package["php"],
  }
  package { 'libcurl3-openssl-dev':
    ensure => installed,
    
  }
  package { 'make':
    ensure => installed,
    }

  service { "mongodb":
    enable => true,
    ensure => running,
    require => Package[$package],
  }

  exec { "install-php-mongo":
    command =>  "pecl install mongo",
    path    => ["/usr/bin", "/usr/sbin"],
    require => Package[php5-dev],
  }     
 
  
  exec { "createdb-admin-user":
    command => "mongo admin --eval 'db.addUser(${admin}, ${admin})'",
    path    => ["/usr/bin", "/usr/sbin"]
  }
  exec { "add_mongo_extension":
    command =>  "sed -i '/default extension directory./a \\ extension=mongo.so '  /etc/php5/cli/php.ini",
  }

  exec {" download_rockmongo":
    command => "wget https://rock-php.googlecode.com/files/'$rockmongo_zip'",
    unless => "/home/ec2-user/'$rockmongo_zip'",
    path    => ["/usr/bin", "/usr/sbin"]
  }
  exec { "tar -xf /Volumes/nfs02/important.tar":
  cwd     => "/var/tmp",
  creates => "/var/tmp/myfile",
  path    => ["/usr/bin", "/usr/sbin"]
}

  file { "/etc/init/mongodb.conf":
    content => template("mongodb/mongodb.conf.erb"),
    mode => "0644",
    notify => Service["mongodb"],
    require => Package[$package],
  }

}

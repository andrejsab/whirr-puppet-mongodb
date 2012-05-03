# Class: mongodb::install
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
class mongodb::install (
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
  

  service { "mongodb":
    enable => true,
    ensure => running,
    require => Package[$package],
  }



 exec { "createdb-user":
    command => "mongo admin --eval \'db.addUser(${admin}, ${admin})\'
                && mongo admin --eval \'db.addUser(${ldr-user}, ${sindice})\' ",
    path => ["/usr/bin", "/usr/sbin"],
    require => Package[$package],
  }

  file { "/etc/init/mongodb.conf":
    content => template("mongodb/mongodb.conf.erb"),
    mode => "0644",
    notify => Service["mongodb"],
    require => Package[$package],
  }

exec {"download-mongo-php-driver":
    command =>"wget https://github.com/mongodb/mongo-php-driver/tarball/master \
               && tar -zxvf master \
               && chmod -R 777 ${mongodb::params::mongo-driver}  \
               && cd  ${mongodb::params::mongo-driver} \
               && phpize \
               && ./configure \
               && make \
               && make install ",
    cwd => "/tmp",
    notify => Service["apache2"],
    path => ["/usr/bin", "/usr/sbin","/bin"],
    require => [Package["php5-dev"],Package["make"],Package["libcurl3-openssl-dev"],Package["php5"]],
  }
 
file {"/tmp":
    ensure => "directory",
  }  
   
  file {["/var/","/var/www/","/var/www/html/",$mongodb::params::rockmongo_dir]:
    mode => "0767",
    ensure => "directory",
  }  
 #file {"/tmp/${mongodb::params::mongo-driver}":
 #   mode => "0777",
 #   ensure => "directory",
 # }  
 
include mongodb::rockmongo
}

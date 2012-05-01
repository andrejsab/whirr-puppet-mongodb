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
 $repository = "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
  $package = "mongodb-10gen"
  $rockmongo_zip = 'rockmongo-v1.1.0.zip'
  $rockmongo_dir = '/var/www/html/rockmongo'
  $admin='"admin"'
  # Name of replica set (if any) to join
  $replSet = ""

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
notify{"1":}
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
notify{"2":}
  package { $package:
    ensure => installed,
    require => Exec["update-apt"],
  }
notify{"3":}  
  package { 'php-pear':
    ensure => installed,
 #   require => Package["php5"],
  }
notify{"4":}
  package { 'php5-dev':
    ensure => installed,
 #   require => Package["php5"],
  }
notify{"5":}
package { 'apache2':
    ensure => installed,
  }
notify{"6":}
package { 'php5':
    ensure => installed,
    require => Package["apache2"],
  }
notify{"7":}
  package { 'libcurl3-openssl-dev':
    ensure => installed,
  }
notify{"8":}
  package { 'make':
    ensure => installed,
  }
notify{"9":}
  package { 'unzip':
    ensure => installed,
  }
notify{"10":}
  service { "mongodb":
    enable => true,
    ensure => running,
    require => Package[$package],
  }
notify{"11":}
  exec { "install-php-mongo":
    command =>  "pecl install mongo",
    path    => ["/usr/bin", "/usr/sbin"],
    require => Package[php5-dev],
  }     
 notify{"12":}
  exec { "add_mongo_extension":
   command =>  "sed -i \'/default extension directory./a \\ extension=mongo.so \'  /etc/php5/cli/php.ini",
    path => ["/bin", "/usr/share/doc/"],
  }
notify{"13":}
  exec {" download_rockmongo":
    command => "wget https://rock-php.googlecode.com/files/${rockmongo_zip}",
    cwd => '/home/andrejs/',
    path => ["/usr/bin", "/usr/sbin"],
  }

notify{"14":}
  file {["/var/","/var/www/","/var/www/html/",$rockmongo_dir]:
    ensure => "directory",
  }  

notify{"15":}
  exec { "unzip-file":
   command => "unzip   /home/andrejs/${rockmongo_zip}",
   cwd => $rockmongo_dir,
   path => ["/usr/bin", "/usr/sbin"],
   require => file[$rockmongo_dir],
}
notify{"16":}
 exec { "createdb-admin-user":
    command => "mongo admin --eval \'db.addUser(${admin}, ${admin})\'",
    path => ["/usr/bin", "/usr/sbin"],
  }
notify{"17":}
 



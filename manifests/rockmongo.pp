# Class: mongodb::rockmongo
#
# 
#
class mongodb::rockmongo{
  

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

  
  service { "apache2":
    enable => true,
    ensure => running,
    require => Package["apache2"],
  }

   
  exec { "add_mongo_extension":
   command =>  "sed -i \'/default extension directory./a \\ extension=mongo.so \'  /etc/php5/apache2/php.ini",
    path => ["/bin", "/usr/share/doc/"],
   notify => Service["apache2"],
    require => Package["php5"],
  }

 exec { "install-php-mongo":
    command =>"chmod -R 777 /tmp/${mongodb::params::mongo-driver} \
                && phpize \
                &&./configure \
               && make \
                 && make install",
    cwd => "/tmp/${mongodb::params::mongo-driver}",
    path => ["/tmp/${mongodb::params::mongo-driver}","/bin","/usr/bin"],
#    require => File["/tmp/${mongodb::params::mongo-driver}"],
  }

  exec {"download-mongo-php-driver":
    command =>"wget https://github.com/mongodb/mongo-php-driver/tarball/master \
               && tar -zxvf master",
    cwd => "/tmp",
    path => ["/usr/bin", "/usr/sbin","/bin"],
    require => [Package["php5-dev"],Package["make"],Package["libcurl3-openssl-dev"],Package["php5"]],
  }

  
   exec { "install-php-mongo":
    command =>"chmod -R 777 /tmp/${mongodb::params::mongo-driver} \
                && phpize \
                &&./configure \
               && make \
                 && make install",
    cwd => "/tmp/${mongodb::params::mongo-driver}",
    path => ["/tmp/${mongodb::params::mongo-driver}","/bin","/usr/bin"],
  }

  
  exec {"download_rockmongo":
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
   command => "chmod -R 777 ${rockmongo_dir} \
         && unzip -f /tmp/${rockmongo_zip}",
   cwd => $rockmongo_dir,
   path => ["/bin","/usr/bin", "/usr/sbin"],
   require => [File[$rockmongo_dir],Package["unzip"]],
}

 

}

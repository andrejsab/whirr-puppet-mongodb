# Class: mongodb::params
#
# This class manages MongoDB parameters
#
# Parameters:
# - The 10gen Ubuntu $repository to use
# - The 10gen Ubuntu $package to use
# - A replica set to join
# - A nofile ulimit
#
# Sample Usage:
#  include mongodb::params
#
class mongodb::params {
  $repository = "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
  $package = "mongodb-10gen"
  $rockmongo_zip = 'rockmongo-v1.1.0.zip'
  $rockmongo_dir = '/var/www/html/rockmongo'
  $mongo-driver = 'mongodb-mongo-php-driver-2ca8000'  # can often change
  $admin='"admin"'
  $ldr-user='"ldr-user"'
  $sindice='"sindice"'
#  $string="mongo admin --eval 'db.addUser("+$admin+", "+$admin+")'"
  # Name of replica set (if any) to join
  $replSet = ""

  # Number of open files ulimit can be changed if mongodb.log reports
  # "too many open files" or "too many open connections" messages.
  # MongoDB has an upper hard limit of 20k.
  # http://www.mongodb.org/display/DOCS/Too+Many+Open+Files
  $ulimit_nofile = 1024
}

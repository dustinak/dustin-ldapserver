# == Class: ldapserver
#
# This class is intended to allow automated management of ldap servers, specifically
# the 389ds and Redhat Directory Server.
#
# === Parameters
#
# [*base*]
#   This is the base DN of your LDAP domain, ex: dc=example,dc=com
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { ldapserver:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Dustin Rice <dustinak@gmail.com>
#
# === Copyright
#
# Copyright 2014 Dustin Rice, unless otherwise noted.
#
class ldapserver {

  include ldapserver::install


}

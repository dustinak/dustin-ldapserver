# == Class: ldapserver
#
# This class is intended to allow automated management of ldap servers,
# specifically the 389ds and Redhat Directory Server.
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
# [*dsadmin*]
#   This is the admin user's password that gets passed into the answers
#   file which gets executed on setup
# [*dirmanager*]
#   This is the directory manager's password that gets passed into the answers
#   file which gets executed on setup
# [*certdb*]
#   The password for the NSS certificate database where 389ds stores it's certs
#   and keys. All three of these password variable could, and probably should, be
#   replaced with hiera lookups
# [*diruser/dirgroup*]
#   User and group to install 389ds as. This should be fine left as 'nobody'.
# [*maxfile*]
#   Max open file descriptors. Depends on your implementation
# [*admindomain*]
#   If you intend to setup the admin server, choose a domain here
# [*base*]
#   This is the base suffix for your domain, ex: dc=example,dc=com
# [*instance*]
#   Choose a short instance idenfier for your domain, ex: example
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
class ldapserver (
  $dsadmin = 'changemenow',
  $dirmanager = 'changemenow',
  $certdb = 'changemenow',
  $diruser = 'nobody',
  $dirgroup = 'nobody',
  $maxfile = '8192',
  $admindomain = 'example.com',
  $base = 'dc=example,dc=com',
  $instance = 'example',
 ) {
  include ldapserver::install
  include ldapserver::service

  # Since this file will contain the directory manager password I've
  # chosen to drop it in root's home
  file { '/root/389dsanswers.inf':
        mode    => '0400',
        owner   => 'root',
        group   => 'root',
        content => template('ldapserver/389dsanswers.erb')
  }

  # Only significant thing in this file is the ulimit setting
  file { '/etc/sysconfig/dirsrv':
        mode    => '0400',
        owner   => 'root',
        group   => 'root',
        content => template('ldapserver/dirsrv.erb')
  }

}

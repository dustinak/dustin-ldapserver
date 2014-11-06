# == Class: ldapserver
#
# This class is intended to allow automated management of ldap servers,
# specifically the 389ds and Redhat Directory Server.
#
# === Parameters
#
# [*suffix*]
#   This is the suffix DN of your LDAP domain, ex: dc=example,dc=com
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
#   and keys. All three of these password variable could, and probably should,
#   be replaced with hiera lookups
# [*diruser/dirgroup*]
#   User and group to install 389ds as. This should be fine left as 'nobody'.
# [*maxfile*]
#   Max open file descriptors. Depends on your implementation
# [*admindomain*]
#   If you intend to setup the admin server, choose a domain here
# [*suffix*]
#   This is the suffix for your domain, ex: dc=example,dc=com
# [*instance*]
#   Choose a short instance idenfier for your domain, ex: example
# [*syntaxcheck*]
#   Enable/disable LDAP syntax checking
# [*accesslogmaxlogsperdir*]
#   Sets the max old access log files to retain
# [*accessloglogmaxdiskspace*]
#   Max disk space that the access logs should take up in MB
# [*accesslogmaxlogsize*]
#   Max access log file size before it rotates in MB
# === Examples
#
#  class { 'ldapserver':      
#    suffix                   => 'dc=company,dc=com',
#    instance                 => 'myco',
#    admindomain              => 'ldap.company.com',
#    syntaxcheck              => 'off',
#    accesslogmaxlogsperdir   => '20',
#    accessloglogmaxdiskspace => '6000',
#    accesslogmaxlogsize      => '500',}
#}
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
  $dsadmin                  = 'changemenow',
  $dirmanager               = 'changemenow',
  $certdb                   = 'changemenow',
  $diruser                  = 'nobody',
  $dirgroup                 = 'nobody',
  $maxfile                  = '8192',
  $admindomain              = 'example.com',
  $suffix                   = 'dc=example,dc=com',
  $instance                 = 'example',
  $syntaxcheck              = 'on',
  $accesslogmaxlogsperdir   = '10',
  $accessloglogmaxdiskspace = '1000',
  $accesslogmaxlogsize      = '300',
  $sslcertpath              = '/etc/pki/tls/certs/server.crt',
  $sslkeypath               = '/etc/pki/tls/private/server.key',
  $sslenable                = false,
){

  include ldapserver::install
  include ldapserver::service

  # Dependencies
  Package['389-ds']              -> Exec['setup389ds']
  Package['389-ds']              -> File ['/etc/sysconfig/dirsrv']

  Exec['setup389ds']             -> Service['dirsrv']
  Exec['setup389ds']             -> Service['dirsrv-admin']
  Exec['setup389ds']             -> File["/etc/dirsrv/slapd-${instance}/pin.txt"]
  Exec['setup389ds']             -> File["/etc/dirsrv/slapd-${instance}/dse.ldif.tmp"]

  # Exec change for dse.ldif changes
  File["/etc/dirsrv/slapd-${instance}/dse.ldif.tmp"]
    ~> Exec['dirsrv-stop']
    ~> Exec['copy-dse']
    -> Service['dirsrv']

  # SSL Bits
  if $sslenable == true {
    # Setup our file resources so we can notify the Nsstools module
    # in the event they change
    ensure_resource('file',$sslcertpath, {'ensure' => 'present' })
    ensure_resource('file',$sslkeypath, {'ensure' => 'present' })

    # SSL Related dependencies and notifications
    Nsstools::Create["/etc/dirsrv/slapd-${instance}"] -> Nsstools::Add_cert_and_key["${instance}-Cert"]
    File["${sslcertpath}"]                            ~> Nsstools::Add_cert_and_key["${instance}-Cert"]
    Nsstools::Add_cert_and_key["${instance}-Cert"]    ~> Service['dirsrv']

    nsstools::create { "/etc/dirsrv/slapd-${instance}":
      owner          => $diruser,
      group          => $dirgroup,
      mode           => '0660',
      password       => $certdb,
      manage_certdir => false,
    }

    nsstools::add_cert_and_key{ "${instance}-Cert":
      certdir => "/etc/dirsrv/slapd-${instance}",
      cert    => $sslcertpath,
      key     => $sslkeypath,
    }
  }

  # Run the setup
  exec { 'setup389ds':
    command => "/usr/sbin/setup-ds-admin.pl --silent -f /root/${instance}answers.inf",
    onlyif  => "/usr/bin/[ ! -e /etc/dirsrv/slapd-${instance} ]",
  }

  # So this is a little odd, I'm making config changes by editting a temporary file
  # then we fire off an exec chain to stop the server, copy the temp file in place, 
  # and then start the service again.
  file { "/etc/dirsrv/slapd-${instance}/dse.ldif.tmp":
    mode    => '0400',
    owner   => $dirsrv,
    group   => $dirgroup,
    content => template('ldapserver/dse.ldif.erb')
  }

  exec { 'dirsrv-stop':
    command     => '/sbin/service dirsrv stop',
    refreshonly => true,
  }

  exec { 'copy-dse':
    command     => "/bin/cp /etc/dirsrv/slapd-${instance}/dse.ldif.tmp /etc/dirsrv/slapd-${instance}/dse.ldif",
    refreshonly => true,
  }

  # Since this file will contain the directory manager password I've
  # chosen to drop it in root's home
  file { "/root/${instance}-answers.inf":
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
  
  # This file is by convention for 389ds. If it's there with the
  # defined password then the admin UI can just open it every time
  file { "/etc/dirsrv/slapd-${instance}/pin.txt":
    mode    => '0400',
    owner   => $diruser,
    group   => $dirgroup,
    content => "Internal (Software) Token:${certdb}"
  }
}

#puppet-ldapserver

[![Build Status](https://travis-ci.org/dustinak/puppet-ldapserver.svg?branch=master)](https://travis-ci.org/dustinak/puppet-ldapserver)

##Overview

NOTE: This is currently a work in progress. Use at your own risk!

This module will setup and manage the configuration on 389ds/RHDS LDAP servers. It
does this by madifying the dse.ldif file. The caveat here is to do this the dirsrv
service must be down, so in the module I have an exec chain to do this.

##Module Description

This module should setup and configure your 389ds/RHDS servers

##Usage
```puppet
  class { 'ldapserver':
    suffix                   => 'dc=example,dc=com',
    instance                 => 'example',
    admindomain              => 'ldap.example.com',
    syntaxcheck              => 'off',
    accesslogmaxlogsperdir   => '20',
    accessloglogmaxdiskspace => '6000',
    accesslogmaxlogsize      => '500',
  }
```
##Notes

##Requirements
* RHEL/CentOS 6
* EPEL repo
* PuppetLabs stdlib Module
* NSSTools Module

##Todo
* Make it work with Debian/Ubuntu
* Make SSL certs update correctly
* Be able to ensure = 'absent' the answers file when it is no longer needed

Copyright (C) 2014 Dustin Rice dustinak@gmail.com

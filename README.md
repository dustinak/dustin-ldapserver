#dustin-ldapserver

##Overview

NOTE: This is currently a work in progress. Use at your own risk!

This module will setup and manage the configuration on 389ds/RHDS LDAP servers

##Module Description

This module should setup and configure your 389ds/RHDS servers

##Usage
```puppet
class { 'ldapserver' :
  base  => 'dc=example,dc=com'
}
```
##Notes

##Requirements
This module expects you have defined EPEL or some other repo that contains
the 389ds packages.

##Todo
* Write it!

Copyright (C) 2014 Dustin Rice dustinak@gmail.com

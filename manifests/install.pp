#
class ldapserver::install {

  package { '389ds':
    ensure => 'installed'
  }

}

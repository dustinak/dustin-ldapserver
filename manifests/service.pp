# Service class for 389ds ldap server

class ldapserver::service {
    service { 'dirsrv':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
    }

    service { 'dirsrv-admin':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
    }
}

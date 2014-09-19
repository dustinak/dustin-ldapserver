#
class ldapserver::params {
    case $::osfamily {
        'redhat': {
        }
        default: { fail_unconfigured() }
    }
}

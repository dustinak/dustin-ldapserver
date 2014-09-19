#
class ldapserver::install {

ensure_packages (['389-ds-base',
            '389-ds-console-doc',
            '389-adminutil',
            '389-ds-base-libs',
            '389-admin',
            '389-ds-console',
            '389-admin-console-doc',
            '389-ds',
            '389-console',
            '389-admin-console',
            '389-dsgw',
            ])
}

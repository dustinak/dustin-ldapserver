require 'spec_helper'

describe 'ldapserver' do
  let(:facts) {{ :operatingsystemmajrelease => '6' }}
  it { should compile }
  it { should contain_class('ldapserver::install') }
  it { should contain_class('ldapserver::service') }

  context 'default parameters' do
    it do
      should contain_file('/etc/dirsrv/slapd-example/dse.ldif.tmp')\
        .with_content(/^nsslapd-syntaxcheck: on$/)\
        .with_content(/^nsslapd-accesslog-maxlogsperdir: 10$/)\
        .with_content(/^nsslapd-accesslog-logmaxdiskspace: 1000$/)\
        .with_content(/^nsslapd-accesslog-maxlogsize: 300$/)\
        .without_content(/^dn: cn=RSA,cn=encryption,cn=config$/)\
        .without_content(/^nsSSLToken: internal \(software\)$/)\
        .without_content(/^nsSSLPersonalitySSL: example-Cert$/)\
        .without_content(/^nsSSLActivation: on$/)\
        .without_content(/^cn: RSA$/)\
        .without_content(/^objectClass: nsEncryptionModule$/)\
        .without_content(/^nsslapd-security: on$/)\
    end

    it do
      should contain_file('/root/example-answers.inf')\
        .with_content(/^config_dir = \/etc\/dirsrv\/slapd-example$/)\
        .with_content(/^RootDNPwd = changemenow$/)\
        .with_content(/^SysUser = nobody$/)\
        .with_content(/^SuiteSpotGroup = nobody$/)\
        .with_content(/^Suffix = dc=example,dc=com$/)\
    end

    it do
      should contain_file('/etc/dirsrv/slapd-example/pin.txt')\
        .with_content(/^Internal \(Software\) Token:changemenow$/)\
    end
  end
  
  context 'with ssl enabled' do
  let(:params) {{ :sslenable => 'true' }}
    it do
      should contain_file('/etc/dirsrv/slapd-example/dse.ldif.tmp')\
        .with_content(/^dn: cn=RSA,cn=encryption,cn=config$/)\
        .with_content(/^nsSSLToken: internal \(software\)$/)\
        .with_content(/^nsSSLPersonalitySSL: example-Cert$/)\
        .with_content(/^nsSSLActivation: on$/)\
        .with_content(/^cn: RSA$/)\
        .with_content(/^objectClass: nsEncryptionModule$/)\
        .with_content(/^nsslapd-security: on$/)\
    end
  end
end

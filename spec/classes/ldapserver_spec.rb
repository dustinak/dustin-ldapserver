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
    end

    it do
      should contain_file('/root/389dsanswers.inf')\
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
end

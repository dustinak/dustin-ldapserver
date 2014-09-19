require 'spec_helper'

describe 'ldapserver' do
  it { should compile }
  it { should contain_class('ldapserver::install') }
  it { should contain_class('ldapserver::service') }

end

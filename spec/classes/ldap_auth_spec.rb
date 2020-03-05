require 'spec_helper'

# Testing private autofs::ldap_auth class via autofs class
describe 'autofs' do
  describe 'private autofs::ldap_auth' do
    let(:params) {{ :ldap => true }}

    context 'supported operating systems' do
      on_supported_os.each do |os, os_facts|

        context "on #{os}" do
          let(:facts) { os_facts }

          context 'with default parameters' do
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to create_class('autofs::ldap_auth') }
            it { is_expected.to create_file('/etc/autofs_ldap_auth.conf').with( {
              :owner   => 'root',
              :group   => 'root',
              :mode    => '0600',
              :content => <<~EOM
                <?xml version="1.0" ?>
                <autofs_ldap_sasl_conf
                  usetls="yes"
                  tlsrequired="yes"
                  authrequired="yes"
                  authtype="LOGIN"
                />
              EOM
            } ) }
          end

          context 'with simp_options::ldap* parameters set' do
            let(:hieradata) { 'simp_options_ldap_params' }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to create_class('autofs::ldap_auth') }
          end

          context 'with all but encoded_secret optional parameters set' do
          end

          context 'with all optional parameters set' do
          end

          context 'with authrequired set to a string' do
          end

          context 'with authtype=EXTERNAL' do
          end
        end
      end
    end
  end
end

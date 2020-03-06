require 'spec_helper'

# Testing private autofs::config class via autofs class
describe 'autofs' do
  describe 'private autofs::config' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default autofs parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it { is_expected.to create_file('/etc/autofs.conf').with( {
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0644',
            :content => <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              mount_verbose = no
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              use_hostname_for_mounts = no
              disable_not_found_message = no
              use_mount_request_log_id = no
            EOM
          } ) }

          it { is_expected.to create_file('/etc/sysconfig/autofs').with( {
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0640',
            :content => <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              USE_MISC_DEVICE="yes"
            EOM
          } ) }

          it { is_expected.to create_file('/etc/auto.master').with( {
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0640',
            :content => <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.

              # This directory is managed by by simp-autofs.
              # - Unmanaged files in this directory will be removed.
              # - No other included directories are managed by simp-autofs.
              +dir:/etc/auto.master.simp.d

              +dir:/etc/auto.master.d
            EOM
          } ) }

          it { is_expected.to create_file('/etc/auto.master.simp.d').with( {
            :ensure  => 'directory',
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0640',
            :recurse => true,
            :purge   => true
          } ) }

          it { is_expected.to create_file('/etc/autofs.maps.simp.d').with( {
            :ensure  => 'directory',
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0640',
            :recurse => true,
            :purge   => true
          } ) }

          it { is_expected.to_not create_class('autofs::ldap_auth') }
        end
      end
    end
  end
end

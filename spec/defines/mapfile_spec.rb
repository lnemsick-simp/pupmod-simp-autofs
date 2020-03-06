require 'spec_helper'

describe 'autofs::mapfile' do
 on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with a direct mapping' do
        let(:title) { '/etc/autofs.maps.simp.d/apps.map'}

        context 'without options' do
          let(:params) {{
            :mappings => {
              'key'      => '/net/apps',
              'location' => '1.2.3.4:/exports/apps'
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('autofs') }
          it { is_expected.to contain_autofs__mapfile(title) }
          it { is_expected.to contain_file(title).with( {
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0640',
            :content => <<~EOM
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              /net/apps    1.2.3.4:/exports/apps
            EOM
          } ) }

          it { is_expected.to contain_file(title).that_notifies('Exec[autofs_reload]') }
        end

        context 'with options' do
          let(:params) {{
            :mappings => {
              'key'      => '/net/apps',
              'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
              'location' => '1.2.3.4:/exports/apps'
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it { is_expected.to contain_file(title).with_content(
            <<~EOM
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              /net/apps  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.4:/exports/apps
            EOM
          ) }

          it { is_expected.to contain_file(title).that_notifies('Exec[autofs_reload]') }
        end
      end

      context 'with a single indirect mapping' do
        let(:title) { '/etc/autofs.maps.simp.d/home.map'}

        context 'without options' do
          let(:params) {{
            :mappings => [ {
              'key'      => '*',
              'location' => '1.2.3.4:/exports/home/&'
            } ]
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it { is_expected.to contain_file(title).with_content(
            <<~EOM
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              *    1.2.3.4:/exports/home/&
            EOM
          ) }

          it { is_expected.to_not contain_file(title).that_notifies('Exec[autofs_reload]') }
        end

        context 'with options' do
          let(:params) {{
            :mappings => [ {
              'key'      => '*',
              'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
              'location' => '1.2.3.4:/exports/home/&'
            } ]
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it { is_expected.to contain_file(title).with_content(
            <<~EOM
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              *  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.4:/exports/home/&
            EOM
          ) }

          it { is_expected.to_not contain_file(title).that_notifies('Exec[autofs_reload]') }
        end
      end

      context 'with a multiple indirect mappings' do
        let(:title) { '/etc/autofs.maps.simp.d/apps.map'}
        let(:params) {{
          :mappings => [
            {
              'key'      => 'app1',
              'location' => '1.2.3.4:/exports/app1'
            },
            {
              'key'      => 'app2',
              'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
              'location' => '1.2.3.5:/exports/app2'
            },
            {
              'key'      => 'app3',
              'location' => '1.2.3.6:/exports/app3'
            },
          ]
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_autofs__mapfile(title) }
        it { is_expected.to contain_file(title).with_content(
          <<~EOM
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            app1    1.2.3.4:/exports/app1
            app2  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.5:/exports/app2
            app3    1.2.3.6:/exports/app3
          EOM
        ) }

        it { is_expected.to_not contain_file(title).that_notifies('Exec[autofs_reload]') }
      end

      context 'with errors' do
        let(:title) { 'home.map' }
        it 'fails when title is not an absolute path' do
          is_expected.to_not compile.with_all_deps
        end
      end
    end
  end
end

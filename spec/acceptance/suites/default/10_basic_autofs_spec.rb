require 'spec_helper_acceptance'

test_name 'basic autofs'

describe 'basic autofs' do

  # only going to use one NFS server
  server = hosts_with_role( hosts, 'nfs_server' ).first
  clients = hosts_with_role( hosts, 'nfs_client' )

  let(:server_fqdn) { fact_on(nfs_server, 'fqdn') }
  let(:client_hieradata) {{
    # Set us up for a basic autofs (no LDAP)
    'simp_options::ldap' => false,
    'simp_options::pki'  => false,
    # set up automounts
    'autofs::maps'       => {
      # indirect mount with multiple explicit keys
      'apps' => {
        'mount_point' => '/net/apps',
        'mappings'    => [
          {
            'key'      => 'app1',
            'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
            'location' => "#{server_fqdn}:/exports/app1"
          },
          {
            'key'      => 'app2',
            'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
            'location' => "#{server_fqdn}:/exports/app2"
          },
          {
            'key'      => 'app3',
            'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
            'location' => "#{server_fqdn}:/exports/app3"
          },
        ]
      },
      # direct mount
      'data' => {
        'mount_point' => '/net/data',
        'mappings'    => {
          'key'      => '/net/apps',
          'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
          'location' => '#{server_fqdn}:/exports/data'
        }
      },
      # indirect mount with wildcard key and key substitution
      'home' => {
        'mount_point'    => '/home',
        'master_options' => 'strictexpire --strict',
        'mappings'       => [ {
          'key'      => '*',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => "#{server_fqdn}:/exports/home/&"
        } ]
      }
    }
  }}

  let(:client_manifest) { 'include autofs' }
  let(:file_content_base) { 'This is a test file from' }
  let(:mounted_files) { [
    '/net/apps/apps1/test_file',
    '/net/apps/apps2/test_file',
    '/net/apps/apps3/test_file',
    '/net/data/test_file',
    '/home/user1/test_file',
    '/home/user2/test_file'
  ] }

  context 'autofs clients' do
    clients.each do |client|
      context "as autofs client #{client} using NFS server #{server}" do
        it "should apply client manifest to mount dirs from #{server}" do
          set_hieradata_on(client, client_hieradata)
          apply_manifest_on(client, client_manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(client, client_manifest, :catch_changes => true)
        end

        it 'should automount NFS shares' do
          mounted_files.each do |file|
            auto_dir = File.dirname(file)
            filename = File.basename(file)
            on(client, %(cd #{auto_dir}; grep '#{file_content_base}' #{filename}))
          end

          on(client, "find #{mount_root_path} -type f | sort")
        end
=begin

        it 'should ensure vagrant connectivity' do
          on(hosts, 'date')
        end

        it 'automount should be valid after client reboot' do
          client.reboot
          wait_for_reboot_hack(client)
          mounted_files.each do |file|
            auto_dir = File.dirname(file)
            filename = File.basename(file)
            on(client, %(cd #{auto_dir}; grep '#{file_content_base}' #{filename}))
          end

          on(client, "find #{mount_root_path} -type f | sort")
        end

        it 'should stop and disable autofs service as prep for next test' do
          # auto-mounted filesystems are unmounted when autofs service is stopped
          on(client, %{puppet resource service autofs ensure=stopped enable=false})
        end
=end
      end
    end
  end
end

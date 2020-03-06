# @summary Create an autofs map file
#
# You will need to create an corresponding `autofs::masterfile` entry for this
# to be activated.  Alternatively, use `autofs::map`, which will create both
# the master entry file and its map file for you.
#
# @see autofs(5)
#
# @param name
#   Fully qualified path of the map file
#
# @param mappings
#   Single direct mapping or one or more indirect mappings
#
#   * Each mapping specifies a key, a location, and any automounter and/or
#     mount options.
#   * Any change to a direct map will trigger a reload of the autofs service.
#     This is not necessary for an indirect map.
#
# @example Create an autofs map file for a direct map
#   autofs::mapfile('/etc/autofs.maps.simp.d/apps.map':
#    mappings => {
#      'key'      => '/net/apps',
#      'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
#      'location' => '1.2.3.4:/exports/apps'
#    }
#
# @example Create an autofs map file for an indirect map with one mapping
#   autofs::mapfile('/etc/autofs.maps.simp.d/home.map':
#    mappings => [
#      {
#        'key'      => '*',
#        'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#        'location' => '1.2.3.4:/exports/home/&'
#      }
#    ]
#
# @example Create an autofs map file for an indirect map with mutiple mappings
#   autofs::mapfile('/etc/autofs.maps.simp.d/apps.map':
#    mappings => [
#      {
#        'key'      => 'app1
#        'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#        'location' => '1.2.3.4:/exports/app1'
#      },
#      {
#        'key'      => 'app2
#        'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#        'location' => '1.2.3.5:/exports/app2'
#      }
#    ]
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::mapfile (
  Variant[Autofs::Directmapping, Array[Autofs::Indirectmapping,1]] $mappings
) {

  if $name !~ Stdlib::Absolutepath {
    fail('"$name" must be a Stdlib::Absolutepath')
  }

  include 'autofs'

  file { $name:
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp("${module_name}/etc/autofs.maps.simp.d/map.epp", {
      'mappings' => $mappings} )
  }

  if $mappings =~ Autofs::Directmapping {
    # Direct map changes are only picked up if the autofs service is reloaded
    File[$name] ~> Exec['autofs_reload']
  }
}

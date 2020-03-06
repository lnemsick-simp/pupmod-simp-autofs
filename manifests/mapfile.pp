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

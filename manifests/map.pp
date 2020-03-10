# @summary Create an auto.master entry file and its corresponding map file
#
# Creates a pair of `autofs::masterfile` and `autofs::mapfile` resources for
# `$name`.
#
# * The auto.master entry will have the default (implied) 'map_type' of 'file',
#   the default (implied) 'map_format' of 'sun', and be written to file in
#   `${autofs::master_conf_dir}`.
# * The corresponding map file will be in 'sun' format and be located in
#   `${autofs::maps_dir}`.
#
# @param name
#   Basename of the map
#
#   * auto.master entry filename will be
#     `${autofs::master_conf_dir}/${name}.autofs`
#   * Corresponding map file will be named `${autofs::maps_dir}/${name}.map`
#   * If `$name` has any whitespace or '/' characters, those characters will be
#     replaced with '__' in order to create safe filenames
#
# @param mount_point
#   Base location for the autofs filesystem to be mounted
#
#   * Set to '/-' for direct maps
#   * Set to a fully-qualified path for indirect mounts
#   * See auto.master(5) -> FORMAT -> mount-point
#
# @param master_options
#   Options for `mount` and/or `automount` specified in the auto.master entry file
#
#   * See auto.master(5) -> FORMAT -> options
#
# @param mappings
#   Single direct mapping or one or more indirect mappings
#
#   * Each mapping specifies a key, a location, and any automounter and/or
#     mount options.
#
# @example Create an autofs master and map files for a direct map
#   autofs::map {'data':
#     mount_point => '/-',
#     mappings    => {
#       'key'      => '/net/data',
#       'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
#       'location' => '1.2.3.4:/exports/data'
#     }
#   }
#
# @example Create an autofs master and map files for an indirect map with wildcard key
#   autofs::map { 'home':
#     mount_point => '/home',
#     mappings    => [
#       {
#         'key'      => '*',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/home/&'
#       }
#     ]
#   }
#
# @example Create an autofs master and map files for an indirect map with multiple keys
#   autofs::map { 'apps':
#     mount_point => '/apps',
#     mappings    => [
#       {
#         'key'      => 'v1',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/apps1'
#       },
#       {
#         'key'      => 'v2',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/apps2'
#       },
#       {
#         'key'      => 'latest',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.5:/exports/apps2'
#       }
#     ]
#   }
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::map(
  Stdlib::Absolutepath                                             $mount_point,
  Optional[String]                                                 $master_options = undef,
  Variant[Autofs::Directmapping, Array[Autofs::Indirectmapping,1]] $mappings
) {

  include 'autofs'

  $_safe_name = regsubst($name, '(/|\s)', '__', 'G')
  $_map_filename = "${autofs::maps_dir}/${_safe_name}.map"

  autofs::masterfile { $_safe_name:
    mount_point => $mount_point,
    map         => $_map_filename,
    options     => $master_options
  }

  autofs::mapfile { $_safe_name:
    mappings => $mappings,
    maps_dir => $autofs::maps_dir
  }

  Autofs::Mapfile[$_safe_name] -> Autofs::Masterfile[$_safe_name]
}

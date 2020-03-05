# @summary Add an auto.master entry file and map file
#
# Creates an autofs::masterfile and an autofs::mapfile resource for $name.
# * The auto.master entry will have the default (implied) 'map_type' of 'file'
#   and the default (implied) 'map_format' of 'sun' and its file will be
#   located in `${autofs::master_conf_dir}`
# * The map file will be in 'sun' format and be located in `${autofs::maps_dir}`
#
# @param name
#   Basename of the map
#
#   * Corresponding auto.master entry filename will be
#     `${autofs::master_conf_dir}/${name}.autofs`
#   * Corresponding map file will be named `${autofs::maps_dir}/${name}.map`

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
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::map(
  Stdlib::Absolutepath                                             $mount_point,
  Optional[String]                                                 $master_options = undef,
  Variant[Autofs::Directmapping, Array[Autofs::Indirectmapping,1]] $mappings
) {

  include 'autofs'

  $_safe_name = regsubst($name, '(/|\s)', '__')
  $_map_filename = "${autofs::maps_dir}/${_safe_name}.map"

  autofs::mapfile { $_map_filename:
    mappings => $mappings
  }

  autofs::masterfile { $_safe_name:
    mount_point => $mount_point,
    map         => $_map_filename,
    options     => $master_options
  }

  Autofs::Mapfile[$_map_filename] -> $Autofs::Masterfile[$_safename]
}

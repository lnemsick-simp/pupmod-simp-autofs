# @summary Manage the installation and configuration of `autofs` and ensure
# its service is running.
#
# @see autofs.conf
#
# @param timeout
#   Sets the 'timeout' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param negative_timeout
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> NEGATIVE_TIMEOUT
#
# @param mount_wait
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# @param umount_wait
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# @param browse_mode
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> BROWSE_MODE
#
# @param append_options
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> APPEND_OPTIONS
#
# @param logging
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> LOGGING
#
# @param ldap_uri
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
#   * Only applies if `$ldap` is `true`.
#
# @param ldap_timeout
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param ldap_network_timeout
#   See: auto.master(5) -> LDAP MAPS -> LDAP_NETWORK_TIMEOUT
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param search_base
#   See: auto.master(5) -> LDAP MAPS -> SEARCH_BASE
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param map_object_class
#   See: auto.master(5) -> LDAP MAPS -> MAP_OBJECT_CLASS
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param entry_object_class
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_OBJECT_CLASS
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param map_attribute
#   See: auto.master(5) -> LDAP MAPS -> MAP_ATTRIBUTE
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param entry_attribute
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_ATTRIBUTE
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param value_attribute
#   See: auto.master(5) -> LDAP MAPS -> VALUE_ATTRIBUTE
#
#   * Only applies if `$ldap` is `true`.
#
#
# @param map_hash_table_size
#   Set the map cache hash table size
#
#   * Should be a power of 2 with a ratio roughly between 1:10 and 1:20 for
#     each map
#
# @param automount_use_misc_device
#   If the kernel supports using the autofs miscellanous device, and you wish
#   to use it, you must set this configuration option to ``yes`` otherwise it
#   will not be used
#
# @param automount_options
#   Options to append to the automount application at start time
#
#   * See ``automount(8)`` for details
#
# @param samba_package_ensure
#   The value to pass to the `ensure` parameter of the `samba-utils` package.
#   Defaults to `simp_options::package_ensure` or `installed`
#
# @param autofs_package_ensure
#   The value to pass to the `ensure` parameter of the `autofs` package.
#   Defaults to `simp_options::package_ensure` or `installed`
#
# @param ldap
#   Enable LDAP lookups
#
#   * Further configuration may need to be made in the `autofs::ldap_auth` class
#
# @param pki
#   * If 'simp', include SIMP's pki module and use pki::copy to manage
#     application certs in /etc/pki/simp_apps/autofs/x509
#   * If true, do *not* include SIMP's pki module, but still use pki::copy
#     to manage certs in /etc/pki/simp_apps/autofs/x509
#   * If false, do not include SIMP's pki module and do not use pki::copy
#     to manage certs.  You will need to appropriately assign a subset of:
#     * app_pki_dir
#     * app_pki_key
#     * app_pki_cert
#     * app_pki_ca
#     * app_pki_ca_dir
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs (
  Integer                       $timeout                        = 600, #default?
  Optional[Integer]             $master_wait                    = undef,
  Optional[Integer]             $negative_timeout               = undef,
  Boolean                       $mount_verbose                  = false,
  Optional[Integer]             $mount_wait                     = undef,
  Optional[Integer]             $umount_wait                    = undef,
  Boolean                       $browse_mode                    = false,
  Integer[3,4]                  $mount_nfs_default_protocol     = 4,
  Boolean                       $append_options                 = true,
  Autofs::Logging               $logging                        = 'none',
  Boolean                       $force_standard_program_map_env = false,
  Optional[Integer]             $map_hash_table_size            = undef,
  Boolean                       $use_hostname_for_mounts        = false,
  Boolean                       $disable_not_found_message      = false,
  Optional[Integer]             $sss_master_map_wait            = undef,
  Boolean                       $use_mount_request_log_id       = false,
  Optional[Simplib::Uri]        $ldap_uri                       = undef,
  Optional[Integer]             $ldap_timeout                   = undef,
  Optional[Integer]             $ldap_network_timeout           = undef,
  Optional[String]              $search_base                    = undef,
  Optional[String]              $map_object_class               = undef,
  Optional[String]              $entry_object_class             = undef,
  Optional[String]              $map_attribute                  = undef,
  Optional[String]              $entry_attribute                = undef,
  Optional[String]              $value_attribute                = undef,
  Stdlib::Absolutepath          $auth_conf_file                 = '/etc/autofs_ldap_auth.conf',
  Hash                          $custom_autofs_conf_options     = {},
  Boolean                       $automount_use_misc_device      = true,
  Optional[String]              $automount_options              = undef,

  #   The primary directory for SIMP-managed auto.master configuration files.
  Stdlib::Absolutepath          $master_conf_dir                = '/etc/auto.master.simp.d',
  #   Other directories of auto.master configuration files to include
  #   * This module will not manage these directories or their contents.
  Array[Stdlib::Absolutepath]   $master_include_dirs            = [ '/etc/auto.master.d' ],
  Stdlib::Absolutepath          $maps_dir                       = '/etc/autofs.maps.simp.d',
# allow user to specify simple 'file' maps in hieradata
  Hash[String,Autofs::Mapspec]  $maps                           = {},
  String                        $samba_package_ensure           = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  String                        $autofs_package_ensure          = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean                       $ldap                           = simplib::lookup('simp_options::ldap', { 'default_value' => false }),
  Variant[Enum['simp'],Boolean] $pki                            = simplib::lookup('simp_options::pki', { 'default_value' => false })
) {

  include 'autofs::install'
  include 'autofs::config'
  include 'autofs::service'

  Class['autofs::install'] -> Class['autofs::config']
  Class['autofs::config'] ~> Class['autofs::service']
}

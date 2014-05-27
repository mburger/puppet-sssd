# = Class: sssd
#
# This is the main sssd class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, sssd class will automatically "include $my_class"
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, sssd main config file will have the param: source => $source
#
# [*source_dir*]
#   If defined, the whole sssd configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, sssd main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#
# [*service_autorestart*]
#   Automatically restarts the sssd service when there is a change in
#   configuration files. Default: true, Set to false if you don't want to
#   automatically restart the service.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove all the resources installed by the module
#   Default: false
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module. Default: false
#
# [*disableboot*]
#   Set to 'true' to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#   Default: false
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet. Default: false
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
class sssd (
  $my_class             = '',
  $source               = '',
  $source_dir           = '',
  $source_dir_purge     = '',
  $template             = '',
  $service_autorestart  = false,
  $options              = {},
  $version              = 'present',
  $absent               = false,
  $disable              = false,
  $disableboot          = false,
  $audit_only           = false,
  $noops                = undef
  ) inherits sssd::params {

  #################################################
  ### Definition of modules' internal variables ###
  #################################################

  # Variables defined in sssd::params
  $package=$sssd::params::package
  $service=$sssd::params::service
  $config_file=$sssd::params::config_file
  $config_dir=$sssd::params::config_dir
  $config_file_mode=$sssd::params::config_file_mode
  $config_file_owner=$sssd::params::config_file_owner
  $config_file_group=$sssd::params::config_file_group

  # Variables that apply parameters behaviours
  $manage_package = $sssd::absent ? {
    true  => 'absent',
    false => $sssd::version,
  }

  $manage_service_enable = $sssd::disableboot ? {
    true    => false,
    default => $sssd::disable ? {
      true    => false,
      default => $sssd::absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $sssd::disable ? {
    true    => 'stopped',
    default =>  $sssd::absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_autorestart = $sssd::service_autorestart ? {
    true    => Service[sssd],
    false   => undef,
  }

  $manage_file = $sssd::absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $sssd::audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $sssd::audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $sssd::source ? {
    ''        => undef,
    default   => $sssd::source,
  }

  $manage_file_content = $sssd::template ? {
    ''        => undef,
    default   => template($sssd::template),
  }


  #######################################
  ### Resourced managed by the module ###
  #######################################

  # Package
  package { $sssd::package:
    ensure  => $sssd::manage_package,
    noop    => $sssd::noops,
  }

  # Service
  service { $sssd::service:
    ensure     => $sssd::manage_service_ensure,
    enable     => $sssd::manage_service_enable,
    require    => Package[$sssd::package],
    noop       => $sssd::noops,
  }

  # Configuration File
  file { 'sssd.conf':
    ensure  => $sssd::manage_file,
    path    => $sssd::config_file,
    mode    => $sssd::config_file_mode,
    owner   => $sssd::config_file_owner,
    group   => $sssd::config_file_group,
    require => Package[$sssd::package],
    notify  => $sssd::manage_service_autorestart,
    source  => $sssd::manage_file_source,
    content => $sssd::manage_file_content,
    replace => $sssd::manage_file_replace,
    audit   => $sssd::manage_audit,
    noop    => $sssd::noops,
  }

  # Configuration Directory
  if $sssd::source_dir {
    file { 'sssd.dir':
      ensure  => directory,
      path    => $sssd::config_dir,
      require => Package[$sssd::package],
      notify  => $sssd::manage_service_autorestart,
      source  => $sssd::source_dir,
      recurse => true,
      purge   => $sssd::source_dir_purge,
      force   => $sssd::source_dir_purge,
      replace => $sssd::manage_file_replace,
      audit   => $sssd::manage_audit,
      noop    => $sssd::noops,
    }
  }


  #######################################
  ### Optionally include custom class ###
  #######################################
  if $sssd::my_class {
    include $sssd::my_class
  }

}

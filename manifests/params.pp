# Class: sssd::params
#
# This class defines default parameters used by the main module class sssd
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to sssd class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class sssd::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'sssd',
  }

  $service = $::operatingsystem ? {
    default => 'sssd',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/sssd',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/sssd/sssd.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0600',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

}

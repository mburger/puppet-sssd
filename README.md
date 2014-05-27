# Puppet module: sssd

This is a Puppet module for sssd.

Based on a template defined in http://github.com/Example42-templates/

Released under the terms of Apache 2 License.


## USAGE - Basic management

* Install sssd with default settings

        class { 'sssd': }

* Install a specific version of sssd package

        class { 'sssd':
          version => '1.0.1',
        }

* Disable sssd service.

        class { 'sssd':
          disable => true
        }

* Remove sssd package

        class { 'sssd':
          absent => true
        }

* Enable auditing without without making changes on existing sssd configuration *files*

        class { 'sssd':
          audit_only => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'sssd':
          noops => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'sssd':
          source => [ "puppet:///modules/example42/sssd/sssd.conf-${hostname}" , "puppet:///modules/example42/sssd/sssd.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'sssd':
          source_dir       => 'puppet:///modules/example42/sssd/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'sssd':
          template => 'example42/sssd/sssd.conf.erb',
        }

* Automatically include a custom subclass

        class { 'sssd':
          my_class => 'example42::my_sssd',
        }

## TESTING
[![Build Status](https://travis-ci.org/example42/puppet-sssd.png?branch=master)](https://travis-ci.org/example42/puppet-sssd)


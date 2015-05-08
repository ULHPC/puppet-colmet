# File::      <tt>colmet-collector.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2014 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: colmet::collector
#
# Configure and manage colmet::collector
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of colmet::collector
#
# == Actions:
#
# Install and configure colmet::collector
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import colmet::collector
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'colmet::collector':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class colmet::collector(
    $ensure       = $colmet::params::ensure,
    $data_dir     = $colmet::params::data_dir,
    $ip_collector = $colmet::params::ip_collector
)
inherits colmet::params
{
    info ("Configuring colmet::collector (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("colmet::collector 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include colmet::collector::debian }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: colmet::collector::common
#
# Base class to be inherited by the other colmet::collector classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class colmet::collector::common {

    # Load the variables used in this module. Check the colmet::collector-params.pp file
    require colmet::params

    git::clone { 'git-colmet':
        ensure => $colmet::collector::ensure,
        path   => '/tmp/colmet',
        source => 'git://scm.gforge.inria.fr/colmet/colmet.git',
    }

    package { $colmet::params::extra_packages:
        ensure     => $colmet::collector::ensure,
    }

    file { $colmet::params::configfile_init:
        ensure  => $colmet::collector::ensure,
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::configfile_mode,
        content => template('colmet/default.erb'),
        notify  => Service[$colmet::params::servicename],
        require => File[$colmet::collector::data_dir]
    }
    file { $colmet::params::servicescript_path :
        ensure  => $colmet::collector::ensure,
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::servicescript_mode,
        content => template('colmet/rc.colmet.erb'),
        notify  => Service[$colmet::params::servicename]
    }

    # Create logfile
    file { $colmet::params::logfile:
        ensure => $colmet::collector::ensure,
        owner  => $colmet::params::logfile_owner,
        group  => $colmet::params::logfile_group,
        mode   => $colmet::params::logfile_mode,
    }

    # restart colmet every hours (memory leak...)
    cron { 'restart_colmet':
        ensure      => $colmet::collector::ensure,
        command     => '/etc/init.d/colmet restart',
        environment => "MAILTO=\"\"",
        user        => 'root',
        hour        => '*/1',
        minute      => '0',
    }

    if $colmet::collector::ensure == 'present' {

        # Here $colmet::collector::ensure is 'present'

        # Create datadir
        file { $colmet::params::data_dir:
            ensure => directory,
            owner  => $colmet::params::service_user,
            group  => $colmet::params::service_group,
            mode   => $colmet::params::data_dir_mode,
        }

        # Install and start the colmet service
        exec { 'python setup.py install':
            alias     => 'install-colmet',
            require   =>  [ Git::Clone['git-colmet'],
                            Package[$colmet::params::extra_packages]
                          ],
            cwd       => '/tmp/colmet',
            path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
            logoutput => on_failure,
            user      => 'root',
        } ->
        service { $colmet::params::servicename:
            ensure    => running,
            name      => $colmet::params::servicename,
            enable    => true,
            require   => [
                            File[$colmet::params::configfile_init],
                            File[$colmet::params::servicescript_path],
                            File[$colmet::params::logfile]
                          ],
            subscribe => File[$colmet::params::configfile_init]
        }
    }
    else
    {
        # Here $colmet::collector::ensure is 'absent'

    }

}


# ------------------------------------------------------------------------------
# = Class: colmet::collector::debian
#
# Specialization class for Debian systems
class colmet::collector::debian inherits colmet::collector::common { }


# File::      <tt>colmet::aggregator.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2014 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: colmet::aggregator
#
# Configure and manage colmet::aggregator
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of colmet::aggregator
#
# == Actions:
#
# Install and configure colmet::aggregator
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import colmet::aggregator
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'colmet::aggregator':
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
class colmet::aggregator(
    $ensure          = $colmet::params::ensure,
    $sampling_period = $colmet::params::sampling_period,
    $data_dir        = $colmet::params::data_dir,
    $ip_aggregator   = $colmet::params::ip_aggregator
)
inherits colmet::params
{
    info ("Configuring colmet::aggregator (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("colmet::aggregator 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include colmet::aggregator::debian }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: colmet::aggregator::common
#
# Base class to be inherited by the other colmet::aggregator classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class colmet::aggregator::common {

    # Load the variables used in this module. Check the colmet::aggregator-params.pp file
    require colmet::params

    git::clone { 'git-colmet':
        ensure    => $colmet::aggregator::ensure,
        path      => '/tmp/colmet',
        source    => 'git://scm.gforge.inria.fr/colmet/colmet.git',
    }

    package { $colmet::params::extra_packages:
        ensure     => $colmet::aggregator::ensure,
    }

    file { $colmet::params::configfile_init:
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::configfile_mode,
        ensure  => $colmet::aggregator::ensure,
        content => template('colmet/default.erb'),
        notify  => Service[$colmet::params::servicename],
        require => File[$colmet::aggregator::data_dir]
    }
    file { $colmet::params::servicescript_path :
        ensure  => $colmet::aggregator::ensure,
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::servicescript_mode,
        content => template('colmet/rc.colmet.erb'),
        notify  => Service[$colmet::params::servicename]
    }

    # Create logfile
    file { $colmet::params::logfile:
        ensure  => $colmet::aggregator::ensure,
        owner   => $colmet::params::logfile_owner,
        group   => $colmet::params::logfile_group,
        mode    => $colmet::params::logfile_mode,
    }

    # restart colmet every hours (memory leak...)
    cron { 'restart_colmet':
        ensure  => $colmet::aggregator::ensure,
        command     => "/etc/init.d/colmet restart",
        environment => "MAILTO=\"\"",
        user        => 'root',
        hour        => '*/1',
        minute      => '0',
    }

    if $colmet::aggregator::ensure == 'present' {

        # Here $colmet::aggregator::ensure is 'present'

        # Create datadir
        file { $colmet::params::data_dir:
            ensure  => directory,
            owner   => $colmet::params::service_user,
            group   => $colmet::params::service_group,
            mode    => $colmet::params::data_dir_mode,
        }

        # Install and start the colmet service
        exec { 'python setup.py install':
            alias       => 'install-colmet',
            require     => [ Git::Clone['git-colmet'],
                             Package[$colmet::params::extra_packages]
                           ],
            cwd         => '/tmp/colmet',
            path        => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
            logoutput   => on_failure,
            user        => 'root',
        } ->
        service { $colmet::params::servicename:
            name       => $colmet::params::servicename,
            enable     => true,
            ensure     => running,
            require    => [
                            File[$colmet::params::configfile_init],
                            File[$colmet::params::servicescript_path],
                            File[$colmet::params::logfile]
                          ],
            subscribe  => File[$colmet::params::configfile_init]
        }
    }
    else
    {
        # Here $colmet::aggregator::ensure is 'absent'

    }

}


# ------------------------------------------------------------------------------
# = Class: colmet::aggregator::debian
#
# Specialization class for Debian systems
class colmet::aggregator::debian inherits colmet::aggregator::common { }


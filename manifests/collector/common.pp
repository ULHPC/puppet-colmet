# File::      <tt>colmet-collector.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2014 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: colmet::collector::common
#
# Base class to be inherited by the other colmet::collector classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class colmet::collector::common {

    # Load the variables used in this module. Check the colmet::collector-params.pp file
    require colmet::params

    vcsrepo { 'git-colmet':
        ensure   => $colmet::collector::ensure,
        provider => git,
        path     => '/tmp/colmet',
        source   => 'git://scm.gforge.inria.fr/colmet/colmet.git',
    }

    package { $colmet::params::extra_packages:
        ensure => $colmet::collector::ensure,
    }

    $notify = $colmet::collector::ensure ? {
                  present => Service[$colmet::params::servicename],
                  absent  => undef
              }
    file { $colmet::params::configfile_init:
        ensure  => $colmet::collector::ensure,
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::configfile_mode,
        content => template('colmet/default.erb'),
        notify  => $notify
    }
    file { $colmet::params::servicescript_path :
        ensure  => $colmet::collector::ensure,
        owner   => $colmet::params::configfile_owner,
        group   => $colmet::params::configfile_group,
        mode    => $colmet::params::servicescript_mode,
        content => template('colmet/rc.colmet-collector.erb'),
        notify  => $notify
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
        command     => "/etc/init.d/${colmet::params::servicename} restart",
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
        } ->
        # Install and start the colmet service
        exec { "python setup.py install --record ${colmet::params::data_dir}.installed_files":
            alias     => 'install-colmet',
            cwd       => '/tmp/colmet',
            path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
            logoutput => on_failure,
            user      => 'root',
            unless    => 'test -e /usr/local/bin/colmet-collector',
            before    => Service[$colmet::params::servicename],
            require   =>  [ Vcsrepo['git-colmet'],
                            Package[$colmet::params::extra_packages]
                          ],
        }

        service { $colmet::params::servicename:
            ensure    => running,
            name      => $colmet::params::servicename,
            enable    => true,
            require   => [
                            File[$colmet::params::configfile_init],
                            File[$colmet::params::servicescript_path],
                            File[$colmet::params::logfile],
                          ],
            subscribe => File[$colmet::params::configfile_init]
        }

    }
    else
    {
        # Here $colmet::collector::ensure is 'absent'
        exec { "cat ${colmet::params::data_dir}.installed_files | xargs rm -rf":
            alias     => 'remove-colmet',
            path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
            logoutput => on_failure,
            user      => 'root',
            onlyif    => 'test -e /usr/local/bin/colmet-collector',
        }
    }

}



# File::      <tt>colmet-params.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2014 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: colmet::params
#
# In this class are defined as variables values that are used in other
# colmet classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class colmet::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of colmet
    $ensure = $colmet_ensure ? {
        ''      => 'present',
        default => "${colmet_ensure}"
    }

    $sampling_period = $colmet_sampling_period ? {
        ''      => '10',
        default => "${colmet_sampling_period}"
    }

    $data_dir = $colmet_data_dir ? {
        ''      => '/home/colmet',
        default => "${colmet_data_dir}"
    }

    $ip_aggregator = $colmet_ip_aggregator ? {
        ''      => '0.0.0.0',
        default => "${colmet_ip_aggregator}"
    }

    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    # colmet packages
    $extra_packages = $::operatingsystem ? {
        default => [
                     'python', 'python-dev', 'python-setuptools', 'python-zmq',
                     'python-tables', 'python-h5py', 'python-pyinotify'
                   ]
    }

    # Log directory
    $logfile = $::operatingsystem ? {
        default => '/var/log/colmet.log'
    }
    $logfile_mode = $::operatingsystem ? {
        default => '0644',
    }
    $logfile_owner = $::operatingsystem ? {
        default => 'colmet',
    }
    $logfile_group = $::operatingsystem ? {
        default => 'adm',
    }

    # colmet associated services
    $servicename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'colmet',
        default                 => 'colmet'
    }
    $service_user = $::operatingsystem ? {
        default => 'colmet',
    }
    $service_group = $::operatingsystem ? {
        default => 'colmet',
    }
    $servicescript_mode = $::operatingsystem ? {
        default => '755',
    }
    $servicescript_path = $::operatingsystem ? {
        default => '/etc/init.d/colmet',
    }

    # Configuration
    $configfile_init = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/default/colmet',
        default                 => '/etc/sysconfig/colmet'
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }
    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }
    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }

    $data_dir_mode = $::operatingsystem ? {
        default => '755'
    }


}


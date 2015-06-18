# File::      <tt>collector.pp</tt>
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
        debian, ubuntu:         { include colmet::collector::common::debian }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}



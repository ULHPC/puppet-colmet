# File::      <tt>params.pp</tt>
# Author::    ULHPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2015 ULHPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'colmet::params'

$names = ["ensure", "data_dir", "ip_collector", "extra_packages", "logfile", "logfile_mode", "logfile_owner", "logfile_group", "servicename", "service_user", "service_group", "servicescript_mode", "servicescript_path", "configfile_init", "configfile_mode", "configfile_owner", "configfile_group", "data_dir_mode"]

notice("colmet::params::ensure = ${colmet::params::ensure}")
notice("colmet::params::data_dir = ${colmet::params::data_dir}")
notice("colmet::params::ip_collector = ${colmet::params::ip_collector}")
notice("colmet::params::extra_packages = ${colmet::params::extra_packages}")
notice("colmet::params::logfile = ${colmet::params::logfile}")
notice("colmet::params::logfile_mode = ${colmet::params::logfile_mode}")
notice("colmet::params::logfile_owner = ${colmet::params::logfile_owner}")
notice("colmet::params::logfile_group = ${colmet::params::logfile_group}")
notice("colmet::params::servicename = ${colmet::params::servicename}")
notice("colmet::params::service_user = ${colmet::params::service_user}")
notice("colmet::params::service_group = ${colmet::params::service_group}")
notice("colmet::params::servicescript_mode = ${colmet::params::servicescript_mode}")
notice("colmet::params::servicescript_path = ${colmet::params::servicescript_path}")
notice("colmet::params::configfile_init = ${colmet::params::configfile_init}")
notice("colmet::params::configfile_mode = ${colmet::params::configfile_mode}")
notice("colmet::params::configfile_owner = ${colmet::params::configfile_owner}")
notice("colmet::params::configfile_group = ${colmet::params::configfile_group}")
notice("colmet::params::data_dir_mode = ${colmet::params::data_dir_mode}")

#each($names) |$v| {
#    $var = "colmet::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}

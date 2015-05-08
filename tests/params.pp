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

include 'ULHPC/colmet::params'

$names = ["ensure", "protocol", "port", "packagename"]

notice("ULHPC/colmet::params::ensure = ${ULHPC/colmet::params::ensure}")
notice("ULHPC/colmet::params::protocol = ${ULHPC/colmet::params::protocol}")
notice("ULHPC/colmet::params::port = ${ULHPC/colmet::params::port}")
notice("ULHPC/colmet::params::packagename = ${ULHPC/colmet::params::packagename}")

#each($names) |$v| {
#    $var = "ULHPC/colmet::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}

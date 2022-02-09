# dkim_filter::internallist_entry
#
# This defined type is responsible for creating the ignore hosts list for the dkim-filter
#
define dkim_filter::extignore_entry (
  $ensure = present,
) {

  dkim_filter::hostsnets_entry { "extignore_hosts_${name}":
      ensure => $ensure,
      file   => $dkim_filter::params::extignore_file,
      entry  => $name,
  }

}

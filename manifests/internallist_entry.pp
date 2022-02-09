define dkim_filter::internallist_entry (
  $ensure = present,
) {

  dkim_filter::hostsnets_entry { "internalhosts_${name}":
      ensure => $ensure,
      file   => $dkim_filter::params::internallist_file,
      entry  => $name,
  }

}

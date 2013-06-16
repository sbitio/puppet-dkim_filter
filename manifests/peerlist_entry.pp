define dkim_filter::peerlist_entry (
  $ensure   = present,
) {

  dkim_filter::hostsnets_entry { "peer_${name}":
      ensure  => $ensure,
      file    => $dkim_filter::params::peerlist_file,
      entry   => $name,
  }

}

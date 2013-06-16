# Loosely based on https://github.com/huit/puppet-dkim_filter_access/blob/master/manifests/entry.pp
define dkim_filter::hostsnets_entry (
  $ensure   = present,
  $file,
  $entry
) {

  require dkim_filter::augeas

  $item_filter        = "*[. = '${entry}']"

  Augeas {
    context => "/files${file}/",
    incl    => $file,
    lens    => 'Dkim_Filter_Hostsnetslist.lns',
    require => [
      Augeas::Lens['dkim_filter_hostsnetslist'],
      File[$file],
    ],
    notify  => Service[$dkim_filter::service_name],
  }

  case $ensure {
    present: {
      # Insert bulk
      augeas { "/files${$file}_${entry}_${ensure}":
        onlyif  => "match ${item_filter} size == 0",
        changes => [
          "defnode myalias 0 '${entry}'",
        ],
      }
    }
    absent: {
      augeas { "/files${$file}_${entry}_${ensure}":
        onlyif  => "match ${item_filter} size > 0",
        changes => "rm ${item_filter}",
      }
    }
    default: {
      fail("Unsupported ensure: ${ensure}")
    }
  }
}

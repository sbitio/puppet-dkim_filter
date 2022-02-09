# dkim_filter::conf_entry
#
# Loosely based on https://github.com/huit/puppet-dkim_filter_access/blob/master/manifests/entry.pp
#
define dkim_filter::conf_entry (
  $key,
  $value,
  $ensure = present,
) {

  require dkim_filter::augeas

  $item_filter = "*[key = '${key}'][value = '${value}']"

  Augeas {
    context => "/files${dkim_filter::params::config_file}/",
    incl    => $dkim_filter::params::config_file,
    lens    => 'Dkim_Filter_Conf.lns',
    require => [
      Augeas::Lens['dkim_filter_conf'],
      File[$dkim_filter::params::config_file],
    ],
    notify  => Service[$dkim_filter::service_name],
  }

  case $ensure {
    present: {
      # Insert bulk
      augeas { "/files${dkim_filter::params::config_file}_${key}_${value}_${ensure}":
        onlyif  => "match ${item_filter} size == 0",
        changes => [
          # TO-DO: rework with defnode
#          "ins 99999 after *[last()]",
          "set 0/key '${key}'",
          "set 0/value '${value}'",
          "set 0/#comment 'Puppet managed line'",
        ],
      }
    }
    absent: {
      augeas { "/files${dkim_filter::params::config_file}_${key}_${value}_${ensure}":
        onlyif  => "match ${item_filter} size > 0",
        changes => "rm ${item_filter}",
      }
    }
    default: {
      fail("Unsupported ensure: ${ensure}")
    }
  }
}

# dkim_filter::key
#
# Loosely based on https://github.com/huit/puppet-dkim_filter_access/blob/master/manifests/entry.pp
#
define dkim_filter::key (
  $selector,
  $domain,
  $key,
  $ensure   = present,
  $subdoms  = false,
) {

  require dkim_filter::augeas

  $domain_dir         = "${$dkim_filter::params::key_dir}/${domain}"
  $private_key_file   = "${domain_dir}/${selector}"
  $item_filter        = "*[sender-pattern = '*@${domain}'][domain = '${domain}'][keyfile = '${private_key_file}']"
  $subdom_item_filter = "*[sender-pattern = '*@*${domain}'][domain = '${domain}'][keyfile = '${private_key_file}']"

  if ! defined(File[$domain_dir]) and $ensure == present {
  # TO-DO: remove if last absent
    file { $domain_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }
  }

  file { "${private_key_file}.private":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $key,
    notify  => Service[$dkim_filter::service_name]
  }

  Augeas {
    context => "/files${dkim_filter::params::keylist_file}/",
    incl    => $dkim_filter::params::keylist_file,
    lens    => 'Dkim_Filter_Keylist.lns',
    require => [
      Augeas::Lens['dkim_filter_keylist'],
      File[$dkim_filter::params::keylist_file],
      File["${private_key_file}.private"],
    ],
    notify  => Service[$dkim_filter::service_name],
  }

  case $ensure {
    present: {
      # Insert bulk
      augeas { "/files${dkim_filter::params::keylist_file}_${selector}_${domain}_${ensure}":
        onlyif  => "match ${item_filter} size == 0",
        changes => [
          # TO-DO: rework with defnode
          "set 0/sender-pattern '*@${domain}'",
          "set 0/domain '${domain}'",
          "set 0/keyfile '${private_key_file}'",
        ],
      }
      if $subdoms {
        augeas { "/files${dkim_filter::params::keylist_file}_${selector}_${domain}_subdoms_${ensure}":
          onlyif  => "match ${subdom_item_filter} size == 0",
          changes => [
            # TO-DO: rework with defnode
            "set 0/sender-pattern '*@*${domain}'",
            "set 0/domain '${domain}'",
            "set 0/keyfile '${private_key_file}'",
          ],
        }
      }
    }
    absent: {
      augeas { "/files${dkim_filter::params::keylist_file}_${selector}_${domain}_${ensure}":
        onlyif  => "match ${item_filter} size > 0",
        changes => "rm ${item_filter}",
      }
      if $subdoms {
        augeas { "/files${dkim_filter::params::keylist_file}_${selector}_${domain}_subdoms_${ensure}":
          onlyif  => "match ${subdom_item_filter} size > 0",
          changes => "rm ${subdom_item_filter}",
        }
      }
    }
    default: {
      fail("Unsupported ensure: ${ensure}")
    }
  }
}

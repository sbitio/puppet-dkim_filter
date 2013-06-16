class dkim_filter::params (
  $socket_type       = 'inet',
  $socket_port       = 54321,
  $socket_bind       = '127.0.0.1',
  $socket_file       = '/var/run/dkim-filter/dkim-filter.sock',
  $conf_d_dir        = '/etc/dkim-filter.d',
  $keys              = {},
  $keylist_name      = 'keys.conf',
  $key_dir           = '/etc/dkim-filter-keys',
  $peers             = [],
  $peerlist_name     = 'peers.conf',
  $internal_hosts    = [],
  $internallist_name = 'internal-hosts.conf',
  $extignore_hosts   = [],
  $extignore_name    = 'external-ignore.conf',
  # trusted hosts will be added to both internallist and extignore
  $trusted_hosts     = [],
  $configure_mta     = '',
  $mta_action        = 'accept'
) {

  $keylist_file      = "${conf_d_dir}/${keylist_name}"
  $peerlist_file     = "${conf_d_dir}/${peerlist_name}"
  $extignore_file    = "${conf_d_dir}/${extignore_name}"
  $internallist_file = "${conf_d_dir}/${internallist_name}"

  case $socket_type {
    'inet', 'local': {
      $socket_def = $socket_type ? {
        'local' => "${socket_type}:${socket_file}",
        'inet'  => "${socket_type}:${socket_port}:${socket_bind}",
      }
    }
    default: {
      fail("Unsupported socket_type: ${socket_type}")
    }
  }
  case $configure_mta {
    '', 'postfix': { }
    default: {
      fail("Unsupported configure_mta: ${configure_mta}")
    }
  }
  case $::operatingsystem {
    ubuntu, debian: {
      $package      = 'dkim-filter'
      $service_name = 'dkim-filter'
      $config_file  = '/etc/dkim-filter.conf'
      $pid_file     = '/var/run/dkim-filter/dkim-filter.pid'
    }
#    redhat, centos: {
#    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}

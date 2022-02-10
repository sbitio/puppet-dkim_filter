# dkim_filter
#
# This class is responsible for installing and configuring the dkim-filter service
#
class dkim_filter (
  $ensure      = 'present',
  $autoupgrade = false
) {

  # See: http://linux.die.net/man/5/dkim-filter.conf

  require dkim_filter::params
  require dkim_filter::augeas

  $package      = $dkim_filter::params::package
  $service_name = $dkim_filter::params::service_name
  $config_file  = $dkim_filter::params::config_file
  $conf_d_dir   = $dkim_filter::params::conf_d_dir

  case $ensure {
    /(present)/: {
      $dir_ensure = 'directory'
      $package_ensure = $autoupgrade ? {
        true    => 'latest',
        false   => 'present',
        default => 'present'
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $dir_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  service { $service_name:
    ensure     => running,
    name       => $service_name,
    hasstatus  => false,
    hasrestart => true,
    enable     => true,
    require    => Package[$package],
  }

  file { $config_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
    notify  => Service[$service_name],
  }

  file { $conf_d_dir:
    ensure  => $dir_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
    notify  => Service[$service_name],
  }

  #Conf
  dkim_filter::conf_entry { 'socket':
    ensure => $ensure,
    key    => 'Socket',
    value  => $dkim_filter::params::socket_def,
  }
  if $dkim_filter::params::keys != {} {
    file { $dkim_filter::params::keylist_file:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package],
      notify  => Service[$service_name],
    }

    file { $dkim_filter::params::key_dir:
      ensure  => $dir_ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      require => Package[$package],
    }

    dkim_filter::conf_entry { 'keylist':
      ensure  => $ensure,
      key     => 'KeyList',
      value   => $dkim_filter::params::keylist_file,
      require => [
        File[$dkim_filter::params::keylist_file],
        File[$dkim_filter::params::key_dir],
      ]
    }
    # TO-DO : remove keyfile from config

    create_resources(dkim_filter::key, $dkim_filter::params::keys)
  }

  # TO-DO: peers and external hosts
  if $dkim_filter::params::peers != [] {
    file { $dkim_filter::params::peerlist_file:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package],
      notify  => Service[$service_name],
    }
    dkim_filter::conf_entry { 'peerlist':
      ensure  => $ensure,
      key     => 'PeerList',
      value   => $dkim_filter::params::peerlist_file,
      require => File[$dkim_filter::params::peerlist_file],
    }
    #$peer_defaults = {
    #  ensure => $ensure,
    #  file   => $dkim_filter::params::peerlist_file,
    #}
    #create_resources(dkim_filter::hostsnets_entry, $dkim_filter::params::peers, $peer_defaults)
#    dkim_filter::hostsnets_entry { "peer_${dkim_filter::params::peers}":
#      ensure  => $ensure,
#      file    => $dkim_filter::params::peerlist_file,
#      entry   => $dkim_filter::params::peers,
#    }
    dkim_filter::peerlist_entry { $dkim_filter::params::peers:
      ensure => $ensure,
    }
  }

  if $dkim_filter::params::internal_hosts != [] or $dkim_filter::params::trusted_hosts != [] {
    file { $dkim_filter::params::internallist_file:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package],
      notify  => Service[$service_name],
    }
    dkim_filter::conf_entry { 'internalhosts':
      ensure  => $ensure,
      key     => 'InternalHosts',
      value   => $dkim_filter::params::internallist_file,
      require => File[$dkim_filter::params::internallist_file],
    }
    dkim_filter::internallist_entry { $dkim_filter::params::internal_hosts:
      ensure => $ensure,
    }
    dkim_filter::internallist_entry { $dkim_filter::params::trusted_hosts:
      ensure => $ensure,
    }
  }

  if $dkim_filter::params::extignore_hosts != [] or $dkim_filter::params::trusted_hosts != [] {
    file { $dkim_filter::params::extignore_file:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$package],
      notify  => Service[$service_name],
    }
    dkim_filter::conf_entry { 'ExternalIgnoreList':
      ensure  => $ensure,
      key     => 'ExternalIgnoreList',
      value   => $dkim_filter::params::extignore_file,
      require => File[$dkim_filter::params::extignore_file],
    }
    dkim_filter::extignore_entry { $dkim_filter::params::extignore_hosts:
      ensure => $ensure,
    }
    dkim_filter::extignore_entry { $dkim_filter::params::trusted_hosts:
      ensure => $ensure,
    }
  }

  if $dkim_filter::params::configure_mta != '' {
    dkim_filter::mta_conf { $dkim_filter::params::configure_mta: }
  }

  $_real_socket_tests = $dkim_filter::params::socket_type ? {
    'local' => $dkim_filter::params::socket_file,
    default => undef,
  }

  $_real_net_tests = $dkim_filter::params::socket_type ? {
    'inet'  => [{
      'port' => $dkim_filter::params::socket_port,
      'host' => $dkim_filter::params::socket_bind,
      'type' => 'TCP',
      # TO-DO: Add smtp protocol
    }],
    #TO-DO: local socket
    default => undef,
  }

  if defined(monit::service_conf) {
    @monit::service_conf { $service_name:
      bin          => $dkim_filter::params::bin,
      pid_file     => $dkim_filter::params::pid_file,
      socket_tests => $_real_socket_tests,
      net_tests    => $_real_net_tests,
      require      => Service[$service_name],
    }
  }

}

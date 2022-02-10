# dkim_filter::mta_conf
#
# This defined type is responsible for configuring the mta
#
define dkim_filter::mta_conf (
  $mta = $title
) {

  case $mta {
    'postfix': {
      $ip = $dkim_filter::params::socket_bind ? {
        'localhost' => '127.0.0.1',
        default     => $dkim_filter::params::socket_bind,
      }
      # params definition has reverse host port order
      $socket_postfix_def = $dkim_filter::params::socket_type ? {
        'local' => "${dkim_filter::params::socket_type}:${dkim_filter::params::socket_file}",
        'inet'  => "${dkim_filter::params::socket_type}:${ip}:${dkim_filter::params::socket_port}",
      }
      postfix::config {
        'smtpd_milters'         : value => $socket_postfix_def;
        'non_smtpd_milters'     : value => $socket_postfix_def;
        'milter_default_action' : value => $dkim_filter::params::mta_action;
      }
    }
    default: {
      fail("Unsupported configure_mta: ${mta}")
    }
  }

}

# dkim_filter::augeas
#
# ##TODO## Add a description
#
class dkim_filter::augeas {
  augeas::lens {'dkim_filter_conf':
    ensure      => present,
    lens_source => 'puppet:///modules/dkim_filter/lenses/dkim_filter_conf.aug',
    test_source => 'puppet:///modules/dkim_filter/lenses/test_dkim_filter_conf.aug',
  }
  augeas::lens {'dkim_filter_keylist':
    ensure      => present,
    lens_source => 'puppet:///modules/dkim_filter/lenses/dkim_filter_keylist.aug',
    test_source => 'puppet:///modules/dkim_filter/lenses/test_dkim_filter_keylist.aug',
  }
  augeas::lens {'dkim_filter_hostsnetslist':
    ensure      => present,
    lens_source => 'puppet:///modules/dkim_filter/lenses/dkim_filter_hostsnetslist.aug',
    test_source => 'puppet:///modules/dkim_filter/lenses/test_dkim_filter_hostsnetslist.aug',
  }
}

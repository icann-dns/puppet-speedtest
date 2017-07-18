# speedtest::params
#
class speedtest::params {
  case $::kernel {
    'FreeBSD': {
      $use_pip = false
      $package = 'py27-speedtest-cli'
    }
    'Linux': {
      case $::lsbdistcodename {
        'trusty': {
          $use_pip = true
          $package = 'speedtest-cli'
        }
        default: {
          $use_pip = false
          $package = 'speedtest-cli'
        }
      }
    }
    default: {
      fail("speedtest does not support ${::kernel}")
    }
  }
  $output_dir       = '/var/tmp'
  $output_file_name = "speedtest-${::fqdn}"
}

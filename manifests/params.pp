# speedtest::params
#
class speedtest::params {
  $output_file_name = "speedtest-${::fqdn}"
  $group = $facts['os']['family'] ? {
    'FreeBSD' => 'wheel',
    default   => 'root',
  }
}

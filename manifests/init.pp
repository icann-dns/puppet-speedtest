# == Class: speedtest
#
class speedtest (
  Enum['present', 'absent']      $ensure            = 'present',
  Stdlib::Absolutepath           $speedtest_run     = '/usr/local/bin/speedtest-run.sh',
  String                         $user              = 'root',
  String                         $group             = 'root',
  Stdlib::Absolutepath           $output_dir        = '/var/tmp/speedtest',
  String                         $output_file_name  = $::speedtest::params::output_file_name,
  String                         $package           = 'speedtest-cli',
  Optional[String]               $location          = undef,
  Integer                        $no_tests          = 1,
  Integer                        $no_test_servers   = 1,
  Boolean                        $upload_test       = true,
  Boolean                        $download_test     = true,
  Enum['json', 'csv']            $output_format     = 'csv',
  Boolean                        $enable_upload     = false,
  Optional[Stdlib::Absolutepath] $upload_dir        = undef,
  Optional[Tea::Host]            $upload_host       = undef,
  Optional[Tea::Puppetsource]    $upload_key_source = undef,
  String                         $upload_user       = 'speedtest',
) inherits speedtest::params {
  $_output_file = "${output_dir}/${output_file_name}.${output_format}"
  package {$package:
    provider => 'pip',
  }
  file {$speedtest_run:
    ensure  => file,
    content => template('speedtest/usr/local/bin/speedtest-run.sh.erb'),
    mode    => '0755',
    group   => $group,
    owner   => $user,
  }
  file{ $output_dir:
    ensure => directory,
    mode   => '0755',
    group  => $group,
    owner  => $user;
  }
  cron {'speedtest-run':
    ensure   => $ensure,
    command  => "/usr/bin/flock -n /var/lock/speedtest-run.lock ${speedtest_run}",
    user     => $user,
    require  => [ Package[$package], File[$speedtest_run]],
    monthday => 18,
    hour     => fqdn_rand(23),
    minute   => fqdn_rand(59),
  }
  if $enable_upload {
    if !$upload_dir or !$upload_key_source or !$upload_user {
      fail('if using enable_upload then you must specify all $upload_dir, $upload_key_source and $upload_user')
    }
    include ::file_upload
    file_upload::upload { 'speedtest':
      ensure           => $ensure,
      data             => $output_dir,
      patterns         => ["${output_file_name}*${output_format}"],
      destination_path => $upload_dir,
      destination_host => $upload_host,
      ssh_key_source   => $upload_key_source,
      ssh_user         => $upload_user,
    }
  }
}

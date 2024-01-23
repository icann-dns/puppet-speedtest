# @summary class to install and run speedtest
# @param ensure the ensure parameter
# @param speedtest_run The script to tun
# @param user The user for files and crons
# @param group The gropu for files and crons
# @param output_dir the output_dir
# @param output_file_name Filename of the output file
# @param package package to install
# @param location the location of the system
# @param no_tests number of test to run
# @param no_test_servers number of servers to test against
# @param monthday which days of the month to run the test
# @param weekday which weekdays to run the test
# @param upload_test run the upload test
# @param download_test run the download test
# @param output_format the output format
# @param upload_dir  the upload directory
# @param upload_host the upload host
# @param upload_key_source the source for the ssh upload key
# @param upload_user the upload user
class speedtest (
  Enum['present', 'absent']      $ensure            = 'present',
  Stdlib::Absolutepath           $speedtest_run     = '/usr/local/bin/speedtest-run.sh',
  String                         $user              = 'root',
  String                         $group             = 'root',
  Stdlib::Absolutepath           $output_dir        = '/var/tmp/speedtest',
  String                         $output_file_name  = "speedtest-${facts['networking']['fqdn']}",
  String                         $package           = 'speedtest-cli',
  Optional[String]               $location          = undef,
  Integer                        $no_tests          = 1,
  Integer                        $no_test_servers   = 1,
  String                         $monthday          = '1-7',
  Integer[0,7]                   $weekday           = 2,
  Boolean                        $upload_test       = true,
  Boolean                        $download_test     = true,
  Enum['json', 'csv']            $output_format     = 'csv',
  Optional[String]               $upload_dir        = undef,
  Optional[Tea::Host]            $upload_host       = undef,
  Optional[Tea::Puppetsource]    $upload_key_source = undef,
  String                         $upload_user       = 'speedtest',
) inherits speedtest::params {
  $_output_file = "${output_dir}/${output_file_name}.${output_format}"
  package { $package:
    provider => 'pip3',
  }
  file { $speedtest_run:
    ensure  => file,
    content => template('speedtest/usr/local/bin/speedtest-run.sh.erb'),
    mode    => '0755',
    group   => $group,
    owner   => $user,
  }
  file { $output_dir:
    ensure => directory,
    mode   => '0755',
    group  => $group,
    owner  => $user;
  }

  cron { 'speedtest-run':
    ensure   => $ensure,
    command  => "test $(date +\\%u) -eq ${weekday} && /usr/bin/flock -n /var/lock/speedtest-run.lock ${speedtest_run}",
    user     => $user,
    monthday => $monthday,
    hour     => [fqdn_rand(23),],
    minute   => [fqdn_rand(60),],
    require  => [Package[$package], File[$speedtest_run]],
  }
  if !$upload_dir or !$upload_key_source or !$upload_user or !$upload_host {
    fail('if using enable_upload then you must specify all $upload_dir, $upload_key_source, $upload_user and $upload_host')
  }
  include file_upload
  file_upload::upload { 'speedtest':
    ensure           => $ensure,
    data             => $output_dir,
    patterns         => ["${output_file_name}*${output_format}"],
    destination_path => $upload_dir,
    destination_host => $upload_host,
    ssh_key_source   => $upload_key_source,
    ssh_user         => $upload_user,
    hour_frequency   => [1 + fqdn_rand(23),],
    minute_frequency => [fqdn_rand(60),],
  }
}

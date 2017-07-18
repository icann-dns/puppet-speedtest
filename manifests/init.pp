# == Class: speedtest
#
class speedtest (
  Enum['present', 'absent']      $ensure            = present,
  Boolean                        $enabled           = true,
  Stdlib::Absolutepath           $speedtest_run     = '/usr/local/bin/speedtest-run.sh',
  String                         $user              = 'root',
  String                         $group             = 'root',
  Stdlib::Absolutepath           $output_dir        = $::speedtest::params::output_dir,
  Stdlib::Absolutepath           $output_file       = $::speedtest::params::output_file,
  Boolean                        $enable_upload     = false,
  Optional[Stdlib::Absolutepath] $upload_dir        = undef,
  Optional[Tea::Host]            $upload_host       = undef,
  Optional[Tea::Puppetsource]    $upload_key_source = undef,
  String                         $upload_user       = 'speedtest',
  Boolean                        $use_pip           = $::speedtest::params::use_pip,
  String                         $package           = $::speedtest::params::package,
) inherits speedtest::params {
  if $use_pip {
    package {$package:
      provider => 'pip',
    }
  } else {
    ensure_package($package)
  }
  file {$speedtest_run:
    ensure => file,
    source => "puppet:///modules/speedtest/${speedtest_run}",
    mode   => '0755',
    group  => $group,
    owner  => $user,
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
  include ::file_upload
  file_upload::upload { 'speedtest':
    ensure           => $ensure,
    data             => $output_dir,
    patterns         => [$output_file],
    destination_path => $upload_dir,
    destination_host => $upload_host,
    ssh_key_source   => $upload_key_source,
    ssh_user         => $upload_user,
  }
}

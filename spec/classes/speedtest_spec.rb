# frozen_string_literal: true

require 'spec_helper'

describe 'speedtest' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'speedtest.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # ensure: "present",
      # speedtest_run: "/usr/local/bin/speedtest-run.sh",
      # user: "root",
      # group: "root",
      # output_dir: "$::speedtest::params::output_dir",
      # output_file_name: "$::speedtest::params::output_file_name",
      # package: "$::speedtest::params::package",
      # location: :undef,
      # tests: "1",
      # upload_test: true,
      # download_test: true,
      # output_format: "csv",
      # enable_upload: false,
      # upload_dir: :undef,
      # upload_host: :undef,
      # upload_key_source: :undef,
      # upload_user: "speedtest",

    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:package) { 'speedtest-cli' }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package(package) }
        it { is_expected.to contain_class('speedtest') }
        it { is_expected.to contain_class('speedtest::params') }
        it do
          is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with(
            ensure: 'file',
            mode: '0755',
            group: 'root',
            owner: 'root'
          ).with_content(
            %r{CMD="speedtest-cli --csv"}
          ).with_content(
            %r{OUTPUT=/var/tmp/speedtest/speedtest-speedtest.example.com.csv}
          ).with_content(
            %r{for i in \{1..1\}}
          )
        end
        it do
          is_expected.to contain_file('/var/tmp/speedtest').with(
            ensure: 'directory',
            mode: '0755',
            group: 'root',
            owner: 'root'
          )
        end
        it do
          is_expected.to contain_cron('speedtest-run').with(
            ensure: 'present',
            command: 'test $(date +%u) -eq 2 && /usr/bin/flock -n /var/lock/speedtest-run.lock /usr/local/bin/speedtest-run.sh',
            user: 'root'
          )
        end
        it { is_expected.not_to contain_file_upload__upload('speedtest') }
      end
      describe 'Change Defaults' do
        context 'ensure' do
          before { params.merge!(ensure: 'absent') }
          it { is_expected.to compile }
          it { is_expected.to contain_cron('speedtest-run').with_ensure('absent') }
        end
        context 'speedtest_run' do
          before { params.merge!(speedtest_run: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/foobar').with(
              ensure: 'file',
              mode: '0755',
              group: 'root',
              owner: 'root'
            )
          end
          it do
            is_expected.to contain_cron('speedtest-run').with(
              ensure: 'present',
              command: 'test $(date +%u) -eq 2 && /usr/bin/flock -n /var/lock/speedtest-run.lock /foobar',
              user: 'root'
            )
          end
        end
        context 'user' do
          before { params.merge!(user: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with(
              ensure: 'file',
              mode: '0755',
              group: 'root',
              owner: 'foobar'
            )
          end
          it do
            is_expected.to contain_cron('speedtest-run').with(
              ensure: 'present',
              command: 'test $(date +%u) -eq 2 && /usr/bin/flock -n /var/lock/speedtest-run.lock /usr/local/bin/speedtest-run.sh',
              user: 'foobar'
            )
          end
        end
        context 'weekday' do
          before { params.merge!(weekday: 5) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_cron('speedtest-run').with(
              ensure: 'present',
              command: 'test $(date +%u) -eq 5 && /usr/bin/flock -n /var/lock/speedtest-run.lock /usr/local/bin/speedtest-run.sh',
              user: 'root'
            )
          end
        end
        context 'group' do
          before { params.merge!(group: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with(
              ensure: 'file',
              mode: '0755',
              group: 'foobar',
              owner: 'root'
            )
          end
        end
        context 'output_dir' do
          before { params.merge!(output_dir: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{OUTPUT=/foobar/speedtest-speedtest.example.com.csv}
            )
          end
        end
        context 'output_file_name' do
          before { params.merge!(output_file_name: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{OUTPUT=/var/tmp/speedtest/foobar.csv}
            )
          end
        end
        context 'package' do
          before { params.merge!(package: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'location' do
          before { params.merge!(location: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{SERVERS="\$\(speedtest-cli --list| awk -F\\\) '/foobar/ \{print \$1\}' | head -1\)"}
            )
          end
        end
        context 'no_test_servers' do
          before { params.merge!(location: 'foobar', no_test_servers: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{SERVERS="\$\(speedtest-cli --list| awk -F\\\) '/foobar/ \{print \$1\}' | head -42\)"}
            )
          end
        end
        context 'no_tests' do
          before { params.merge!(no_tests: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{for i in \{1..42\}}
            )
          end
        end
        context 'upload_test' do
          before { params.merge!(upload_test: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{CMD="speedtest-cli --csv --no-upload"}
            )
          end
        end
        context 'download_test' do
          before { params.merge!(download_test: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{CMD="speedtest-cli --csv --no-download"}
            )
          end
        end
        context 'output_format' do
          before { params.merge!(output_format: 'json') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/bin/speedtest-run.sh').with_content(
              %r{CMD="speedtest-cli --json"}
            ).with_content(
              %r{OUTPUT=/var/tmp/speedtest/speedtest-speedtest.example.com.json}
            )
          end
        end
        context 'enable_upload' do
          before do
            params.merge!(
              enable_upload: true,
              upload_dir: '/foobar',
              upload_host: 'foobar',
              upload_key_source: 'puppet:///modules/foobar'
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.not_to contain_file_upload__upload('speedtest').with(
              ensure: 'present',
              data: '/var/tmp',
              patterns: ['/var/tmp/speedtest/speedtest-speedtest.example.org'],
              destination_path: '/foobar',
              destination_host: 'foorbar',
              ssh_key_source: 'puppet:///modules/foobar',
              ssh_user: 'speedtest'
            )
          end
        end
      end
      describe 'check bad type' do
        context 'ensure' do
          before { params.merge!(ensure: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ensure bad string' do
          before { params.merge!(ensure: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'speedtest_run' do
          before { params.merge!(speedtest_run: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'user' do
          before { params.merge!(user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'group' do
          before { params.merge!(group: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'output_dir' do
          before { params.merge!(output_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'output_file_name' do
          before { params.merge!(output_file_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'package' do
          before { params.merge!(package: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'location' do
          before { params.merge!(location: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tests' do
          before { params.merge!(tests: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_test' do
          before { params.merge!(upload_test: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'download_test' do
          before { params.merge!(download_test: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'output_format' do
          before { params.merge!(output_format: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable_upload' do
          before { params.merge!(enable_upload: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_dir' do
          before { params.merge!(upload_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_host' do
          before { params.merge!(upload_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_key_source' do
          before { params.merge!(upload_key_source: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'upload_user' do
          before { params.merge!(upload_user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end

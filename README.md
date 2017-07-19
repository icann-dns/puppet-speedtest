# puppet-speedtest

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with speedtest](#setup)
    * [What speedtest affects](#what-speedtest-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with speedtest](#beginning-with-speedtest)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Basic Config](#basic-config)
    * [Transferring files](#transferring-files)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Overview
puppet module to install and manage

[speedtest-cli](https://github.com/sivel/speedtest-cli). It allows to
run as a cronjob and save the result into an output file.

## Module Description

This module will install speedtest-cli (script based on python) that
can be used to test internet bandwidth using speedtest.net servers.

This module provides the ability to run a cronjob, capture the
output and using `::file_upload` will transfer the output to a central
location

## Setup

### What speedtest affects

* installs and manages speedtest-cli
* If enabled, creates a cronjob that will use `::file_upload` to secure copy the output to a central location


### Setup requirements

* Python > 2.7
* file_upload


### Beginning with speedtest

Install the module

```puppet
class {'::speedtest':
  ensure => present
}
```

In hiera

```puppet
speedtest::ensure: present
```

## Usage

### Basic config

Set the output directory and format

```puppet
class {'::speedtest':
  output_dir    => '/var/tmp',
  output_file   => 'speedtest-out',
  output_format => 'csv'
}
```

### Transferring files

If want to enable upload, set that up with

```puppet
class {'::speedtest':
  enabled_upload    => true,
  upload_dir        => '/opt/upload',
  upload_host       => 'example.org',
  upload_key_source => <ssh_key_user>,
  upload_user       => 'user',
}
```

## Reference

### Public classes

* `ensure` (<present|absent>, Default: present): To activate or not the module so the file structure and scripts can be created
* `speedtest_run` (Stdlib:Absolutepath, Default:
'/usr/local/bin/speedtest-run.sh'): Location and name for the script that will run the cronjob
* `user` (String, Default: 'root'): user that owns the directory where output is saved
* `group` (String, Default: 'root'): group that owns the directory where output is saved
* `location` (Optional|String, Default: undef): Closest city to test the bandwidth against to.
* `output_format` (<json|csv>, Default: 'csv'): Output format after run the test
* `enable_upload` (Boolean, Default: false): Enable the use of `::file_upload`
* `upload_dir` (Optional|Stdlib:Absolutepath,, Default: undef): Location of remote host to upload output
* `upload_host` (Optional|Tea::Host, Default: undef): Hostname or IP of the remote host to upload the output
* `upload_key_source` (Optional|Tea:Puppetsource, Default: undef): puppet resource that defines where the ssh key is located to conect to the remote host (Note: the public/private key pair must be created before using this module and configured on the other host as well)
* `upload_user` (String, Default: 'speedtest'): username of the remote user host to upload the output

### Private classes

#### Class `speedtest::params`

Set specific parameters about the package and where to locate outputs


## Limitations

This module has been tested on:

* Ubuntu 16.04

## Development

Pull requests welcome but please also update documentation and tests.

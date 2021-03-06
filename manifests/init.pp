# == Class: ntp
#
# This module manages the ntp service.
#
class ntp (
  $config_file_owner   = 'root',
  $config_file_group   = 'root',
  $config_file_mode    = '0644',
  $package_latest      = false,
  $package_name        = 'USE_DEFAULTS',
  $package_noop        = 'USE_DEFAULTS',
  $package_source      = 'USE_DEFAULTS',
  $package_adminfile   = 'USE_DEFAULTS',
  $service_name        = 'USE_DEFAULTS',
  $config_file         = 'USE_DEFAULTS',
  $driftfile           = 'USE_DEFAULTS',
  $service_running     = true,
  $service_hasstatus   = true,
  $service_hasrestart  = true,
  $keys                = 'USE_DEFAULTS',
  $servers             = ['0.us.pool.ntp.org',
                          '1.us.pool.ntp.org',
                          '2.us.pool.ntp.org'],
  $server_options      = 'UNSET',
  $peers               = 'UNSET',
  $restrict_options    = 'USE_DEFAULTS',
  $restrict_localhost  = 'USE_DEFAULTS',
  $step_tickers_ensure = 'USE_DEFAULTS',
  $step_tickers_path   = '/etc/ntp/step-tickers',
  $step_tickers_owner  = 'root',
  $step_tickers_group  = 'root',
  $step_tickers_mode   = '0644',
  $orphan_mode_stratum = 'UNSET',
  $fudge_stratum       = '10',
  $enable_stats        = false,
  $enable_tinker       = 'USE_DEFAULTS',
  $statsdir            = '/var/log/ntpstats/',
  $logfile             = 'UNSET',
  $ignore_local_clock  = false,
  $disable_monitor     = false,
) {

  # validate type as array or fail
  validate_array($servers)

  # validate type and convert string to boolean if necessary
  if is_string($package_latest) == true {
    $my_package_latest = str2bool($package_latest)
  } else {
    $my_package_latest = $package_latest
  }

  # validate type and convert string to boolean if necessary
  if is_string($service_running) == true {
    $my_service_running = str2bool($service_running)
  } else {
    $my_service_running = $service_running
  }

  # validate type and convert string to boolean if necessary
  if is_string($service_hasstatus) == true {
    $my_service_hasstatus = str2bool($service_hasstatus)
  } else {
    $my_service_hasstatus = $service_hasstatus
  }

  # validate type and convert string to boolean if necessary
  if is_string($service_hasrestart) == true {
    $my_service_hasrestart = str2bool($service_hasrestart)
  } else {
    $my_service_hasrestart = $service_hasrestart
  }

  if $peers != 'UNSET' {
    if is_array($peers) == true {
      $my_peers = $peers
      validate_array($my_peers)
    }
    elsif is_hash($peers) == true {
      $my_peers = $peers
      validate_hash($my_peers)
    }
    elsif is_string($peers) == true {
      $my_peers = any2array($peers)
      validate_array($my_peers)
    }
    else {
      fail('ntp::peers must be a string or an array or an hash.')
    }
  }

  # validate type and convert string to boolean if necessary
  if is_string($enable_stats) == true {
    $my_enable_stats = str2bool($enable_stats)
  } else {
    $my_enable_stats = $enable_stats
  }
  validate_bool($my_enable_stats)

  if $my_package_latest == true {
    $package_ensure = latest
  } else {
    $package_ensure = present
  }

  if $my_service_running == true {
    $service_ensure = running
    $service_enable = true
  } else {
    $service_ensure = stopped
    $service_enable = false
  }

  if is_string($ignore_local_clock) == true {
    $ignore_local_clock_real = str2bool($ignore_local_clock)
  } else {
    $ignore_local_clock_real = $ignore_local_clock
  }
  validate_bool($ignore_local_clock_real)

  if is_bool($disable_monitor) == true {
    $disable_monitor_real = $disable_monitor
  } else {
    $disable_monitor_real = str2bool($disable_monitor)
  }
  validate_bool($disable_monitor_real)

  case $::osfamily {
    'Debian': {
      $default_package_name        = [ 'ntp' ]
      $default_package_noop        = false
      $default_package_source      = undef
      $default_package_adminfile   = undef
      $default_restrict_options    = [ '-4 default kod notrap nomodify nopeer noquery', '-6 default kod notrap nomodify nopeer noquery', ]
      $default_restrict_localhost  = [ '127.0.0.1', '::1', ]
      $default_step_tickers_ensure = 'absent'
      $default_service_name        = 'ntp'
      $default_config_file         = '/etc/ntp.conf'
      $default_driftfile           = '/var/lib/ntp/ntp.drift'
      $default_keys                = '/etc/ntp/keys'
      $default_enable_tinker       = true
    }
    'RedHat': {
      $default_package_name        = [ 'ntp' ]
      $default_package_noop        = false
      $default_package_source      = undef
      $default_package_adminfile   = undef
      $default_restrict_options    = [ '-4 default kod notrap nomodify nopeer noquery', '-6 default kod notrap nomodify nopeer noquery', ]
      $default_restrict_localhost  = [ '127.0.0.1', '::1', ]
      $default_step_tickers_ensure = 'present'
      $default_service_name        = 'ntpd'
      $default_config_file         = '/etc/ntp.conf'
      $default_keys                = '/etc/ntp/keys'
      $default_enable_tinker       = true
      if $::operatingsystemmajrelease == '7' or $::lsbmajdistrelease == '7' {
        $default_driftfile           = '/var/lib/ntp/drift'
      } else {
        $default_driftfile           = '/var/lib/ntp/ntp.drift'
      }
    }
    'Suse': {
      $default_package_noop        = false
      $default_package_source      = undef
      $default_package_adminfile   = undef
      $default_restrict_options    = [ '-4 default kod notrap nomodify nopeer noquery', '-6 default kod notrap nomodify nopeer noquery', ]
      $default_restrict_localhost  = [ '127.0.0.1', '::1', ]
      $default_step_tickers_ensure = 'absent'
      $default_service_name        = 'ntp'
      $default_config_file         = '/etc/ntp.conf'
      $default_driftfile           = '/var/lib/ntp/drift/ntp.drift'
      $default_keys                = ''
      $default_enable_tinker       = true

      case $::lsbmajdistrelease {
        '9','10': {
          $default_package_name     = [ 'xntp' ]
        }
        '11','12': {
          $default_package_name     = [ 'ntp' ]
        }
        default: {
          fail("The ntp module is supported by release 9, 10, 11 and 12 of the Suse OS Family. Your release is ${::lsbmajdistrelease}")
        }
      }
    }
    'Solaris': {
      case $::kernelrelease {
        '5.9','5.10': {
          $default_package_name       = [ 'SUNWntp4r', 'SUNWntp4u' ]
          $default_restrict_options   = [ 'default noserve noquery', ]
          $default_restrict_localhost = [ '127.0.0.1', ]
        }
        '5.11': {
          $default_package_name       = [ 'network/ntp' ]
          $default_restrict_options   = [ 'default kod notrap nomodify nopeer noquery', ]
          $default_restrict_localhost = [ '127.0.0.1', '::1', ]
        }
        default: {
          fail("The ntp module supports Solaris kernel release 5.9, 5.10 and 5.11. You are running ${::kernelrelease}.")
        }
      }
      $default_package_noop        = true
      $default_package_source      = '/var/spool/pkg'
      $default_package_adminfile   = '/var/sadm/install/admin/puppet-ntp'
      $default_step_tickers_ensure = 'absent'
      $default_service_name        = 'ntp4'
      $default_config_file         = '/etc/inet/ntp.conf'
      $default_driftfile           = '/var/ntp/ntp.drift'
      $default_keys                = '/etc/inet/ntp.keys'
      $default_enable_tinker       = false
    }
    default: {
      fail("The ntp module is supported by OS Families Debian, RedHat, Suse, and Solaris. Your operatingsystem, ${::operatingsystem}, is part of the osfamily, ${::osfamily}")
    }
  }

  if $package_name == 'USE_DEFAULTS' {
    $package_name_real = $default_package_name
  } else {
    $package_name_real = $package_name
  }

  if !is_string($package_name_real) and !is_array($package_name_real) {
    fail('ntp::package_name must be a string or an array.')
  }

  if $package_noop == 'USE_DEFAULTS' {
    $package_noop_real = $default_package_noop
  } else {
    $package_noop_real = $package_noop
  }

  if $package_source == 'USE_DEFAULTS' {
    $package_source_real = $default_package_source
  } else {
    $package_source_real = $package_source
  }

  if $package_adminfile == 'USE_DEFAULTS' {
    $package_adminfile_real = $default_package_adminfile
  } else {
    $package_adminfile_real = $package_adminfile
  }

  if $service_name == 'USE_DEFAULTS' {
    $service_name_real = $default_service_name
  } else {
    $service_name_real = $service_name
  }

  if $config_file == 'USE_DEFAULTS' {
    $config_file_real = $default_config_file
  } else {
    $config_file_real = $config_file
  }

  if $driftfile == 'USE_DEFAULTS' {
    $driftfile_real = $default_driftfile
  } else {
    $driftfile_real = $driftfile
  }

  if $driftfile_real {
    validate_absolute_path($driftfile_real)
  }

  if $step_tickers_ensure == 'USE_DEFAULTS' {
    $step_tickers_ensure_real = $default_step_tickers_ensure
  } else {
    $step_tickers_ensure_real = $step_tickers_ensure
  }
  validate_re($step_tickers_ensure_real, '^(present)|(absent)$',
    "ntp::step_tickers_ensure must be 'present' or 'absent'. Detected value is <${step_tickers_ensure_real}>.")

  validate_absolute_path($step_tickers_path)

  if $keys == 'USE_DEFAULTS' {
    $keys_real = $default_keys
  } else {
    $keys_real = $keys
  }

  if $keys_real {
    validate_absolute_path($keys_real)
  }

  if is_bool($enable_tinker) == true {
    $enable_tinker_real = $enable_tinker
  } else {
    $enable_tinker_real = $enable_tinker ? {
      'USE_DEFAULTS' => $default_enable_tinker,
      default        => str2bool($enable_tinker)
    }
  }

  validate_absolute_path($statsdir)

  if is_array($restrict_options) == true {
    $restrict_options_real = $restrict_options
  }
  # needed for backward compatibility
  elsif is_string($restrict_options) == true {
    $restrict_options_real = $restrict_options ? {
      'USE_DEFAULTS' => $default_restrict_options,
      default        => [ "-4 ${restrict_options}", "-6 ${restrict_options}", ]
    }
  }
  else {
    fail('restrict_options must be an array (prefered) or a string (will be deprecated).')
  }

  if is_array($restrict_localhost) == true {
    $restrict_localhost_real = $restrict_localhost
  }
  elsif $restrict_localhost == 'USE_DEFAULTS' {
    $restrict_localhost_real = $default_restrict_localhost
  }
  else {
    fail('restrict_localhost must be an array or the string \'USE_DEFAULTS\'.')
  }

  if $package_adminfile_real != undef {

    file { 'admin_file':
      ensure  => 'present',
      path    => $package_adminfile_real,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('ntp/solaris_admin_file.erb'),
    }
  }

  package { $package_name_real:
    ensure    => $package_ensure,
    noop      => $package_noop_real,
    source    => $package_source_real,
    adminfile => $package_adminfile_real,
  }

  file { 'ntp_conf':
    ensure  => file,
    path    => $config_file_real,
    owner   => $config_file_owner,
    group   => $config_file_group,
    mode    => $config_file_mode,
    content => template('ntp/ntp.conf.erb'),
    require => Package[$package_name_real],
  }

  if $step_tickers_ensure_real == 'present' {

    $step_tickers_dir = dirname($step_tickers_path)
    validate_absolute_path($step_tickers_dir)

    common::mkdir_p { $step_tickers_dir: }

    file { 'step_tickers_dir':
      ensure  => directory,
      path    => $step_tickers_dir,
      owner   => $step_tickers_owner,
      group   => $step_tickers_group,
      mode    => $step_tickers_mode,
      require => Common::Mkdir_p[$step_tickers_dir],
    }

    file { 'step-tickers':
      ensure  => $step_tickers_ensure_real,
      path    => $step_tickers_path,
      owner   => $step_tickers_owner,
      group   => $step_tickers_group,
      mode    => $step_tickers_mode,
      content => template('ntp/step-tickers.erb'),
      require => [ Package[$package_name_real],
                  File['step_tickers_dir'],
                  ],
    }
  }

  service { 'ntp_service':
    ensure     => $service_ensure,
    name       => $service_name_real,
    enable     => $service_enable,
    hasstatus  => $my_service_hasstatus,
    hasrestart => $my_service_hasrestart,
    subscribe  => [ Package[$package_name_real],
                    File['ntp_conf'],
                  ],
  }

  if $::virtual == 'xenu' and $::kernel == 'Linux' {
    exec { 'xen_independent_wallclock':
      path    => '/bin:/usr/bin',
      command => 'echo 1 > /proc/sys/xen/independent_wallclock',
      unless  => 'grep ^1 /proc/sys/xen/independent_wallclock',
      onlyif  => 'test -f /proc/sys/xen/independent_wallclock',
    }
  }
}

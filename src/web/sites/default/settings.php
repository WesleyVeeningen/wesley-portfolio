<?php

// @codingStandardsIgnoreFile

# Settings file that is always loaded for all environments.

$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => getenv('MYSQL_DATABASE'),
  'username' => getenv('MYSQL_USER'),
  'password' => getenv('MYSQL_PASSWORD'),
  'host' => getenv('MYSQL_HOSTNAME'),
  'port' => '3306',
  'prefix' => '',
  'init_commands' => [
    'isolation_level' => 'SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED',
  ],
);

$settings['trusted_host_patterns'] = [
  '^.*\.vdmi$',
];

$settings['hash_salt'] = 'iypLsDYBcbkxZ7R9DH01lCJ6cCNkPY8YnOyayMuSPrWLQcUq5lIsf5NlQ6giHY2rkKLYJxVX5e97CdNp03i3D3WXC9auls6DT0h7jzP1qcr0bSWJ6ub';

$settings['config_sync_directory'] = '../config';

$settings['file_public_path'] = 'sites/default/files';

$settings['file_private_path'] = 'sites/default/files/private';

$settings['file_temp_path'] = 'sites/default/files/private/tmp';

$config['system.logging']['error_level'] = 'hide';
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;
$config['system.performance']['cache']['page']['max_age'] = 3600;

// If not cli
if (PHP_SAPI !== 'cli') {
  // Fix HTTPS if we're behind load balancer.
  if (getenv('HTTPS') !== 'on' && getenv('HTTP_X_FORWARDED_PROTO') === 'https') {
    $_SERVER['HTTPS'] = 'on';
  }
  // Fix reverse proxy settings if we're behind load balancer.
  if (getenv('HTTP_X_FORWARDED_FOR')) {
    $settings['reverse_proxy'] = TRUE;
    $settings['reverse_proxy_addresses'] = [$_SERVER['REMOTE_ADDR']];
  }
}

# Load a 'settings.env-development.php' settings override.
#    (or 'settings.env-production.php')
if (file_exists($app_root . '/' . $site_path . '/settings.env-' . strtolower(getenv('APP_ENVIRONMENT')) . '.php')) {
  include $app_root . '/' . $site_path . '/settings.env-' . strtolower(getenv('APP_ENVIRONMENT')) . '.php';
}

# Load a 'settings.local.php' settings override.
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}

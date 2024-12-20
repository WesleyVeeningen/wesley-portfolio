if [ ! -d src/web/sites/default ]; then
  mkdir -p src/web/sites/default
fi
if [ ! -d src/config ]; then
  mkdir -p src/config
fi
chmod 777 src/config
touch src/web/sites/default/settings.php
#chmod 777 src/web/sites/default/settings.php
cat <<'EOF' > 'src/web/sites/default/settings.php'
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

$settings['hash_salt'] = '#HASH_SALT#';

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
EOF
DRUPAL_HASH=`openssl rand -base64 $(( $RANDOM % 52 + 72 ))|tr -dc _A-Z-a-z-0-9`
sed -i "s/#HASH_SALT#/${DRUPAL_HASH}/" src/web/sites/default/settings.php


cat <<'EOF' > 'src/web/sites/default/settings.env-development.php'
<?php

error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);
$config['system.logging']['error_level'] = 'verbose';
$config['config_split.config_split.development']['status'] = TRUE;

$config['stage_file_proxy.settings']['origin'] = getenv('DRUPAL_SFP_ORIGIN');
$config['stage_file_proxy.settings']['origin_dir'] = 'sites/default/files';
$config['stage_file_proxy.settings']['hotlink'] = FALSE;
$config['stage_file_proxy.settings']['use_imagecache_root'] = TRUE;
$config['stage_file_proxy.settings']['verify'] = TRUE;


$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
$config['system.performance']['cache']['page']['max_age'] = 0;
EOF

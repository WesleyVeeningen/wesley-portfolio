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

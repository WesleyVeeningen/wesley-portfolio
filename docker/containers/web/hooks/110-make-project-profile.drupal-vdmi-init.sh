if [ ! -d src/web/profiles/custom/${DRUPAL_PROJECT_NAME} ]; then
  mkdir -p src/web/profiles/custom/${DRUPAL_PROJECT_NAME}
fi

# Get a Drupal Profile Name
DRUPAL_PROJECT_HUMAN_NAME_DEFAULT=$(sed -r 's/(^|-)(\w)/\U\2/g' <<<"$PROJECT_NAME")
read -r -e -p "Enter a human name for the Drupal Profile [${DRUPAL_PROJECT_HUMAN_NAME_DEFAULT}]: " DRUPAL_PROJECT_HUMAN_NAME
DRUPAL_PROJECT_HUMAN_NAME=${DRUPAL_PROJECT_HUMAN_NAME:-$DRUPAL_PROJECT_HUMAN_NAME_DEFAULT}
echo ""

# Get a Drupal Profile Description
DRUPAL_PROJECT_DESCRIPTION_DEFAULT="Website ${DRUPAL_PROJECT_HUMAN_NAME}"
read -r -e -p "Enter a description for the Drupal Profile [${DRUPAL_PROJECT_DESCRIPTION_DEFAULT}]: " DRUPAL_PROJECT_DESCRIPTION
DRUPAL_PROJECT_DESCRIPTION=${DRUPAL_PROJECT_DESCRIPTION:-$DRUPAL_PROJECT_DESCRIPTION_DEFAULT}
echo ""

cat <<EOF > "src/web/profiles/custom/${DRUPAL_PROJECT_NAME}/composer.json"
{
    "name": "vdmi-profile/${DRUPAL_PROJECT_NAME}",
    "type": "drupal-custom-profile",
    "description": "VDMi ${DRUPAL_PROJECT_NAME} profile.",
    "homepage": "https://www.vdmi.nl",
    "license": "GPL-2.0-or-later",
    "require": {
    }
}
EOF
cat <<EOF > "src/web/profiles/custom/${DRUPAL_PROJECT_NAME}/${DRUPAL_PROJECT_NAME}.info.yml"
name: ${DRUPAL_PROJECT_HUMAN_NAME}
type: profile
description: '${DRUPAL_PROJECT_DESCRIPTION}'
core_version_requirement: '^8.8 || ^9'
base profile: vdmibase
EOF
cat <<EOF > "src/web/profiles/custom/${DRUPAL_PROJECT_NAME}/${DRUPAL_PROJECT_NAME}.profile"
<?php
/**
 * @file
 * Enables modules and site configuration for this site installation.
 */

// Add any custom code here like hook implementations.
EOF
cat <<EOF > "src/web/profiles/custom/${DRUPAL_PROJECT_NAME}/${DRUPAL_PROJECT_NAME}.install"
<?php
/**
 * @file
 * Install, update and uninstall functions for the ${DRUPAL_PROJECT_NAME} install profile.
 */

/**
 * Implements hook_install().
 *
 * Perform actions to set up the site for this profile.
 *
 * @see system_install()
 */
function ${DRUPAL_PROJECT_NAME}_install() {
  // First, do everything in vdmibase profile.
  include_once DRUPAL_ROOT . '/profiles/custom/vdmibase/vdmibase.install';
  vdmibase_install();

  // Can add code in here to make nodes, terms, etc.
}
EOF
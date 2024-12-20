#!/bin/bash

# Allow unset variables.
set +u

# Download branches from drupal/recommended-project
#  and parse the versions.
POSSIBLE_DRUPAL_VERSIONS=($(wget -q -O - https://api.github.com/repos/drupal/recommended-project/branches | grep -Po '"name":.*?[^\\]",' | awk -F':' '{print $2}'| sed 's/ //g; s/"//g; s/,//g'))

# Ask a version
echo ""
echo $"Select a Drupal version to install."
for (( i=1; i<=${#POSSIBLE_DRUPAL_VERSIONS[@]}; i++ )); do
  POSSIBLE_VERSION=${POSSIBLE_DRUPAL_VERSIONS[$i-1]}
  PADDING=$"     "
  VISUAL_INDEX=${PADDING:0:-${#i}}${i}
  echo $"${VISUAL_INDEX}) ${POSSIBLE_VERSION}"
done
echo ""
while [ -z "${DRUPAL_VERSION}" ]; do
  DEFAULT_VERSION=$((${#POSSIBLE_DRUPAL_VERSIONS[@]} - 1))
  read -p $"Which version of Drupal to install? [${DEFAULT_VERSION}] " INDEX
  [ ! -z "${INDEX}" ] || INDEX=$DEFAULT_VERSION
  case ${INDEX} in
    (*[!0-9]*)
    ;;
    (*)
      DRUPAL_VERSION=${POSSIBLE_DRUPAL_VERSIONS[$INDEX-1]}
    ;;
  esac
done
echo ""
echo "$DRUPAL_VERSION" > .tmp-drupal-version
export DRUPAL_VERSION

# Disallow unset variables (back to default).
set -u

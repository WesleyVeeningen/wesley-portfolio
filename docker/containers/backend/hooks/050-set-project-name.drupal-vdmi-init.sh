export DRUPAL_PROJECT_NAME=$(echo "$PROJECT_NAME"| sed 's/[^a-zA-Z0-9_]/_/g')

export DRUPAL_VERSION=$(<.tmp-drupal-version)

export MAIN_DRUPAL_VERSION=$(echo "$DRUPAL_VERSION" | sed 's@^[^0-9]*\([0-9]\+\).*@\1@')

rm .tmp-drupal-version

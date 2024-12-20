#!/bin/bash
set -euo pipefail
CMD=$@;
if [ "${CMD}" = "install-optimized" ]; then
  # see: https://getcomposer.org/doc/articles/autoloader-optimization.md
  # --optimize-autoloader
  # --classmap-authoritative
  # --apcu-autoloader
  CMD='install --no-ansi --no-interaction --no-progress --no-suggest --optimize-autoloader --apcu-autoloader'
  if [ "${APP_ENVIRONMENT}" != 'development' ]; then
    CMD=$CMD' --no-dev'
  fi
  echo "Running: composer ${CMD}"
fi
$(dirname $0)/composer-org $CMD;

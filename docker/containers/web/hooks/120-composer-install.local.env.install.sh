# Only run in development (devs should do this manually and correctly themselves for the other environments)
if [ "${ENVIRONMENT}" = 'development' ]; then
echo "Running composer install"
# Try composer install
(
  set -euo pipefail
  flock -n 200

  "$(dirname "$0")"/start web &> /dev/null

  "$(dirname "$0")"/shell web /usr/bin/composer install

  "$(dirname "$0")"/stop web &> /dev/null

) 200>/dev/null
RETVAL=$?

# Show status of composer install
echo ""
if [ $RETVAL -ne 0 ]; then
  echo -e "--- \033[1mcomposer install failed\033[0m ---"
  echo "Please manually execute composer install"
else
  echo -e "--- \033[1mcomposer install succesfull\033[0m ---"
fi
echo ""
fi

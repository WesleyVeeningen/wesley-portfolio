[[ ! -f docker/config/drupal.local.env ]] && cp docker/config/drupal.example.env docker/config/drupal.local.env


# Get a Drupal weburi
echo ""
DRUPAL_URI_DEFAULT='https://'
if [ "${ENVIRONMENT}" = 'development' ]; then
    DRUPAL_URI_DEFAULT="https://web.${PROJECT_NAME}.vdmi"
fi
read -r -e -p "Enter the url for this install [${DRUPAL_URI_DEFAULT}]: " DRUPAL_URI
DRUPAL_URI=${DRUPAL_URI:-$DRUPAL_URI_DEFAULT}
echo ""

ESCAPED_DRUPAL_URI=$(printf '%s\n' "${DRUPAL_URI}" | sed -e 's/[]\/$*.^[]/\\&/g');
sed -i "s/https:\/\/external-url/${ESCAPED_DRUPAL_URI}/" docker/config/drupal.local.env

# Get a Drupal stage file proxy url
if [ "${ENVIRONMENT}" != 'production' ]; then
    ORIGIN_URI_DEFAULT='https://'
    read -r -e -p "Enter the origin url (url where stage_file_proxy retrieves its content) [${ORIGIN_URI_DEFAULT}]: " ORIGIN_URI
    ORIGIN_URI=${ORIGIN_URI:-$ORIGIN_URI_DEFAULT}
    echo ""
    ESCAPED_ORIGIN_URI=$(printf '%s\n' "${ORIGIN_URI}" | sed -e 's/[]\/$*.^[]/\\&/g');
    sed -i "s/https:\/\/origin-url/${ESCAPED_ORIGIN_URI}/" docker/config/drupal.local.env
fi
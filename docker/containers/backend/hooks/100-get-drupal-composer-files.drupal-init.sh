
wget -q -O - https://raw.githubusercontent.com/drupal/recommended-project/${DRUPAL_VERSION}/composer.json > src/composer.json
echo "vendor/" > src/.gitignore

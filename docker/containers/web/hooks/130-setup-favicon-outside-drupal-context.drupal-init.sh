# Add patch to project (the patch updates the htaccess file)
mkdir src/patches

cp "$(dirname "${BASH_SOURCE[0]}")"/files/htaccess_favicon_changes.patch src/patches

# Create the favicon.php file
cp "$(dirname "${BASH_SOURCE[0]}")"/files/favicon.php src/

# add patch to composer.json

# Add the patch
"$(dirname "${BASH_SOURCE[0]}")"/files/bash-json-user --file=src/composer.json --key="extra.patches.drupal/core.Htaccess file for favicon outside Drupal context" --value="patches/htaccess_favicon_changes.patch" > src/.composer-tmp.json

# Save changes
cp src/.composer-tmp.json src/composer.json

# Remove temp file
rm src/.composer-tmp.json

echo -e "\033[1mTIP! Use a formatter on the src/composer.json file...\033[0m"

sleep 2

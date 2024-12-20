if [ ! -d src/web/sites/default ]; then
  mkdir -p src/web/sites/default
fi
if [ ! -d persistent-data/files ]; then
  mkdir -p persistent-data/files
  chmod 777 persistent-data/files
fi
if [ ! -f src/web/sites/default/files ]; then
  ln -s ../../../../persistent-data/files src/web/sites/default/files
fi
#!/bin/sh

cd /var/www/html/web/sites/default
if [ ! -d files ]
  then
    ln -s ../../../../persistent-data/files
fi

cd /var/www/persistent-data/files
if [ ! -d private ]
  then
    mkdir private
fi

cd private
if [ ! -d tmp ]
  then
    mkdir tmp
fi

chmod -R 755 /var/www/persistent-data/files
chown -R www-data:www-data /var/www/persistent-data/files

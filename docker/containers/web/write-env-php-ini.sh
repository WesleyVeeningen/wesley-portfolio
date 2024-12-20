#!/bin/bash

# Set XDEBUG Client host as env var, default the gateway
if [ -z "${PHP_xdebug__client_host-}" ];then # client host set by env var.. respect that!
  GATEWAY=`/sbin/ip route | awk '/default/ { print $3 }'`
  XDEBUG_ENABLED=`php -v|grep -i Xdebug|wc -l`
  if [ "${XDEBUG_ENABLED}" -eq 1 ]; then
    export PHP_xdebug__client_host=$GATEWAY
  fi
fi


INIFILE="/usr/local/etc/php/conf.d/zzz-php-env.ini"

# make empty
rm -f $INIFILE
touch $INIFILE

# Incomming: PHP_opcache__validate_timestamps=0
# Target: opcache.validate_timestamps = 0

# fetch all env vars starting wit PHP_ followed by 1 lowercase char
PHP_SETTINGS=`printenv |grep ^PHP_[a-z].*=`
for STR in $PHP_SETTINGS; do
  # all after =
  VAL=${STR#*=}
  # all before =
  SETTING=${STR%=*}
  #replace 2 underscore with dot
  SETTING=${SETTING/__/.}
  # remove PHP_
  SETTING=${SETTING:4}
  # write out to ini . file.
  echo $SETTING" = "$VAL>> $INIFILE
done

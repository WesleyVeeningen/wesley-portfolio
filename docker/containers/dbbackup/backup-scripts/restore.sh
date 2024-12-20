#!/usr/bin/env bash

ROOT_DIR=/backup

for ((i = 1; i <= $#; i++ )); do
  case $i in
      1 )
        FILE_NAME="${@:$i:1}"
      ;;
  esac
done

if [ -z "${FILE_NAME}" ]; then
  echo ""
  echo $"Select a filename to restore."
  POSSIBLE_FILES=($(find $ROOT_DIR -name *.sql.gz | sort -n))
  for (( i=1; i<=${#POSSIBLE_FILES[@]}; i++ )); do
    POSSIBLE_FILE_NAME=${POSSIBLE_FILES[$i-1]}
    POSSIBLE_FILE_NAME=${POSSIBLE_FILE_NAME:(${#ROOT_DIR}+1)}
    PADDING=$"     "
    VISUAL_INDEX=${PADDING:0:-${#i}}${i}
    echo $"${VISUAL_INDEX}) ${POSSIBLE_FILE_NAME}"
  done
  echo $"    q) quit"
  echo ""
  while [ -z "${FILE_NAME}" ]; do
    read -p $"Which backup to restore? [q] " INDEX
    [ ! -z "${INDEX}" ] || INDEX="quit"
    case ${INDEX} in
      ([qQ]*)
        echo $"quit."
        exit 0
      ;;
      (*[!0-9]*)
      ;;
      (*)
        FILE_NAME=${POSSIBLE_FILES[$INDEX-1]}
        FILE_NAME=${FILE_NAME:(${#ROOT_DIR}+1)}
      ;;
    esac
  done
  echo ""
fi

log () {
  echo "$1" >> /var/log/cron.log
  [ ! -z "$2" ] || echo "$1"
  return 0
}

# Normalize path
FILE_NAME=$(realpath ${ROOT_DIR}/${FILE_NAME})
FILE_NAME=${FILE_NAME:(${#ROOT_DIR}+1)}

if [ "${FILE_NAME: -7}" != ".sql.gz" ]; then
  echo $"Error: extension of the file is not .sql.gz."
  exit 1
fi

if [ "${FILE_NAME:0:7}" != "manual/" ] && [ "${FILE_NAME:0:15}" != "automated/week/" ] \
   && [ "${FILE_NAME:0:14}" != "automated/day/" ] && [ "${FILE_NAME:0:15}" != "automated/hour/" ]; then
  echo $"Error: file is not in backup folder."
  exit 2
fi

if [ ! -f "${ROOT_DIR}/${FILE_NAME}" ]; then
  echo $"Error: $FILE_NAME not found."
  exit 3
fi

log $"Starting restore"
log $"MYSQL_HOSTNAME: ${MYSQL_HOSTNAME}"
log $"MYSQL_PORT: ${MYSQL_PORT}"
log $"MYSQL_USER: ${MYSQL_USER}"
log $"FILE: ${FILE_NAME}"

if ! nc -z $MYSQL_HOSTNAME $MYSQL_PORT 2>/dev/null; then
  MAX_CYCLES=$((SECONDS_WAIT_TIMEOUT*5))
  CYCLE=0
  log $"Waiting mysql to launch on ${MYSQL_HOSTNAME}:${MYSQL_PORT}..."
  while ! nc -z $MYSQL_HOSTNAME $MYSQL_PORT 2>/dev/null; do
    sleep 0.2 # wait
    CYCLE=$((CYCLE+1))
    if [ $CYCLE -gt $MAX_CYCLES ]; then
      log $"Error: Waited ${SECONDS_WAIT_TIMEOUT} seconds and no mysql. I'm out."
      log $"" no-stdout
      exit 3
    fi
  done
  log $"Mysql found on ${MYSQL_HOSTNAME}:${MYSQL_PORT}; Starting restore..."
fi

set -o pipefail
gunzip -c "${ROOT_DIR}/${FILE_NAME}" | mysql -u "root" -h "${MYSQL_HOSTNAME}" -P "${MYSQL_PORT}" -p${MYSQL_ROOT_PASSWORD} > /mysql-errors 2>&1
EXIT_STATUS=$?

case $EXIT_STATUS in
    0 )
      log $"STATUS: succes"
      ;;
    * )
      log $"STATUS: error"
      log $"Error:"
      cat /mysql-errors
    ;;
esac
log $"End restore"
log $"" no-stdout

exit $EXIT_STATUS

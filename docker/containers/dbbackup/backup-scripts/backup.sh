#!/usr/bin/env bash

ROOT_DIR=/backup
FILE_SUFFIX=`date +%Y-%m-%d_%H-%M-%S`
for ((i = 1; i <= $#; i++ )); do
  case $i in
      1 )
        BACKUP_TYPE="${@:$i:1}"
      ;;
      2 )
        FILE_PREFIX="${@:$i:1}"
      ;;
  esac
done
[ ! -z "${BACKUP_TYPE}" ] || BACKUP_TYPE="manual"
[ ! -z "${FILE_PREFIX}" ] || FILE_PREFIX=""
FILE_PREFIX=${FILE_PREFIX//[^[:alpha:]._-]/-}
FILE_PREFIX=${FILE_PREFIX:0:64}
[ -z "${FILE_PREFIX}" ] || FILE_PREFIX="${FILE_PREFIX}-"

case $BACKUP_TYPE in
    [mM]* )
      OUTPUT_DIR="${ROOT_DIR}/manual"
    ;;
    [hH]* )
      OUTPUT_DIR="${ROOT_DIR}/automated/hour"
    ;;
    [dD]* )
      OUTPUT_DIR="${ROOT_DIR}/automated/day"
    ;;
    [wW]* )
      OUTPUT_DIR="${ROOT_DIR}/automated/week"
    ;;
    * )
      echo $"Usage: $0 {manual|hourly|daily|weekly} <file_frefix>"
      exit 1
esac

if [ ! -d $OUTPUT_DIR ]; then
  echo $"Error: $OUTPUT_DIR not found."
  exit 2
fi

FILE_PATH="${OUTPUT_DIR}/${FILE_PREFIX}${MYSQL_HOSTNAME}-${FILE_SUFFIX}.sql"
RELATIVE_FILE_PATH=${FILE_PATH:(${#ROOT_DIR}+1)}

log () {
  case $BACKUP_TYPE in
      [mM]* )
        echo "$1" >> /var/log/cron.log
      ;;
  esac
  [ ! -z "$2" ] || echo "$1"
  return 0
}

cleanup () {
  case $BACKUP_TYPE in
      [mM]* )
        log $"Cleanup ${OUTPUT_DIR:(${#ROOT_DIR}+1)} skipped"
        log $"  We keep all manual backups"
        return 0
      ;;
  esac
  log $"Cleanup ${OUTPUT_DIR:(${#ROOT_DIR}+1)}"
  ls -tp $OUTPUT_DIR | grep '.sql.gz$' | tail -n +$((BACKUPS_TO_KEEP+1)) | xargs -I {} rm -- $OUTPUT_DIR/{}
  return 0
}

log $"Starting backup"
log $"BACKUP_TYPE: ${BACKUP_TYPE}"
log $"FILE_PREFIX: ${FILE_PREFIX}"
log $"BACKUPS_TO_KEEP: ${BACKUPS_TO_KEEP}"
log $"MYSQL_HOSTNAME: ${MYSQL_HOSTNAME}"
log $"MYSQL_PORT: ${MYSQL_PORT}"
log $"MYSQL_USER: ${MYSQL_USER}"
log $"FILE: ${RELATIVE_FILE_PATH}"

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
fi
# Get the cache table names to ignore them
set -o pipefail
SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
names=($(mysql -u "root" -h "${MYSQL_HOSTNAME}" -P "${MYSQL_PORT}" -p${MYSQL_ROOT_PASSWORD}<<<"select CONCAT(table_schema, '.', table_name) from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'cache\_%'")) # split the `names` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS
IGNORED_TABLES_STRING=''
# Create skipped tables string
for (( i=0; i<${#names[@]}; i++ ))
do
  if ! [[ $i =~ 0 ]] ; then
    set -o pipefail
    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'.'      # Change IFS to newline char
    row=(${names[$i]})
    IFS=$SAVEIFS   # Restore original IFS
    IGNORED_TABLES_STRING+=" --ignore-table=${row[0]}.${row[1]}"
  fi
done
# Create actual backup without the cache tables
mysqldump -u "root" -h "${MYSQL_HOSTNAME}" -P "${MYSQL_PORT}" -p${MYSQL_ROOT_PASSWORD} --all-databases ${IGNORED_TABLES_STRING} > $FILE_PATH
# Add to the backup the cache tables schema (without cache data)
for (( i=0; i<${#names[@]}; i++ ))
do
  if ! [[ $i =~ 0 ]] ; then
    set -o pipefail
    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'.'      # Change IFS to newline char
    row=(${names[$i]})
    IFS=$SAVEIFS   # Restore original IFS
    mysqldump -u "root" -h "${MYSQL_HOSTNAME}" -P "${MYSQL_PORT}" -p${MYSQL_ROOT_PASSWORD} --compact --no-create-db --no-data "${row[0]}" "${row[1]}" >> $FILE_PATH
  fi
done
# gzip backup
gzip $FILE_PATH
EXIT_STATUS=$?

case $EXIT_STATUS in
    0 )
      log $"STATUS: succes"
      cleanup
      ;;
    * )
      log $"STATUS: error"
    ;;
esac
log $"End backup"
log $"" no-stdout

exit $EXIT_STATUS

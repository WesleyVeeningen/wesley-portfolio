#!/usr/bin/env bash

# Be strict
set -Eeuo pipefail

# Create folder structure (if not exsits)
[ -d /backup/automated/week ] || mkdir -p /backup/automated/week
[ -d /backup/automated/day ] || mkdir -p /backup/automated/day
[ -d /backup/automated/hour ] || mkdir -p /backup/automated/hour
[ -d /backup/manual ] || mkdir -p /backup/manual
chown -R developer:developers /backup

# Tell the world we are here.
echo "" >> /var/log/cron.log
echo "--- start up ---" >> /var/log/cron.log
echo "" >> /var/log/cron.log

# Automate by writing cron instructions
printenv|grep -v '^_=' > /etc/environment
echo "0 0 * * 1 root echo \"\" > /var/log/cron.log 2>&1" > /etc/cron.d/truncate-log
echo "10 */${BACKUP_INTERVAL_HOURS} * * * developer /opt/backup-scripts/backup.sh hourly >> /var/log/cron.log 2>&1" > /etc/cron.d/hourly
echo "14 1 * * * developer /opt/backup-scripts/backup.sh daily >> /var/log/cron.log 2>&1" > /etc/cron.d/daily
echo "18 1 * * 0 developer /opt/backup-scripts/backup.sh weekly >> /var/log/cron.log 2>&1" > /etc/cron.d/weekly
chmod 0755 /etc/cron.d/*

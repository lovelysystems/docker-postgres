#!/bin/bash
set -e

echo "Generating cron schedules"
echo "${BARMAN_BACKUP_SCHEDULE:-0 4 * * *} barman /usr/bin/notify_if_fails '/usr/bin/barman backup --wait all' '${NOTIFY_BACKUP_ERROR_MESSAGE:-Backup failed for $PGUSER@$PGHOST}'" >> /etc/cron.d/barman

echo "Initializing done"

exec "$@"

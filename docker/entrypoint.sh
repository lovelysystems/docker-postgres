#!/bin/bash
set -e

echo "Generating cron schedules"
echo "${BARMAN_BACKUP_SCHEDULE} barman /usr/local/bin/barman backup --wait all" >> /etc/cron.d/barman

echo "Initializing done"

exec "$@"

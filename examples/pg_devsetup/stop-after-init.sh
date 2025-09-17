#!/usr/bin/env bash
set -Eeo pipefail

# Ensure the script is run as the 'postgres' user
if [ "$(id -u)" = "0" ]; then
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

docker-entrypoint.sh postgres &
POSTGRES_PID=$!

# Wait for a fixed 10 seconds
sleep 5

# Stop the PostgreSQL server
kill -SIGTERM "$POSTGRES_PID"
wait "$POSTGRES_PID"
echo "PostgreSQL initialization complete. PGDATA folder is ready."

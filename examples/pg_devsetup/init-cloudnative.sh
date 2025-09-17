#!/bin/bash
set -e

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PGUSER="${PGUSER:-postgres}"

# Debug logging
echo "Starting with PGDATA=$PGDATA, PGUSER=$PGUSER"
ls -l "$PGDATA"

# Ensure correct ownership
chown -R $PGUSER:$PGUSER "$PGDATA"

# Initialize database if PGDATA is empty (no PG_VERSION file)
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "Initializing database cluster in $PGDATA..."
  initdb -D "$PGDATA"
fi

echo "Launching postgres..."
postgres -c shared_preload_libraries=plugin_debugger

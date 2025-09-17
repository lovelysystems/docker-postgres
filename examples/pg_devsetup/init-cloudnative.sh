#!/bin/bash
set -e

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PGUSER="${PGUSER:-postgres}"
# Ensure correct ownership
chown -R $PGUSER:$PGUSER "$PGDATA"
postgres -c shared_preload_libraries=plugin_debugger

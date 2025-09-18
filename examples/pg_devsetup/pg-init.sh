#!/bin/bash
set -e

if [ ! -f "$PGDATA/PG_VERSION" ]; then
  mkdir -p "$PGDATA"
  gosu postgres initdb --username=postgres -D "$PGDATA"
  echo "initialized PGDATA at $PGDATA"
  echo "host all all 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"
else
  echo "PGDATA already initialized."
fi

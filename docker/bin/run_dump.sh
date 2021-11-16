#!/usr/bin/env bash
set -e
source /usr/local/lib/utils.sh

if [ "$(id -u)" = '0' ]; then
  log "this script must be run as postgres user"
  exit 1
fi

dump_file=$1
init_script=$2

log "running dump using init_script=$init_script and dumpfile=$dump_file"
source /usr/local/bin/docker-entrypoint.sh
docker_setup_env
docker_verify_minimum_env
docker_init_database_dir
pg_setup_hba_conf
# PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
# e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
docker_temp_server_start
docker_setup_db

# make sure the script runs in its directory
cd "$SCHEMA_DIR/sql"
log "running init script $init_script"
docker_process_init_files "$init_script"

pg_dump $DIFFDB_DUMP_OPTIONS -f $dump_file
docker_temp_server_stop
unset PGPASSWORD

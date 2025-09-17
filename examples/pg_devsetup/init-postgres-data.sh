#!/usr/bin/env bash
set -Eeo pipefail

# Minimal subset of the official docker-entrypoint.sh to initialize PGDATA and run init scripts
# This script is meant to run in the official postgres image as a one-shot init container.

# usage: file_env VAR [DEFAULT]
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    printf >&2 'error: both %s and %s are set (but are exclusive)\n' "$var" "$fileVar"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

# create initial directories and ensure ownership
docker_create_db_directories() {
  local user; user="$(id -u)"

  mkdir -p "$PGDATA"
  chmod 00700 "$PGDATA" || :

  mkdir -p /var/run/postgresql || :
  chmod 03775 /var/run/postgresql || :

  if [ -n "${POSTGRES_INITDB_WALDIR:-}" ]; then
    mkdir -p "$POSTGRES_INITDB_WALDIR"
    if [ "$user" = '0' ]; then
      find "$POSTGRES_INITDB_WALDIR" \! -user postgres -exec chown postgres '{}' +
    fi
    chmod 700 "$POSTGRES_INITDB_WALDIR"
  fi

  if [ "$user" = '0' ]; then
    find "$PGDATA" \! -user postgres -exec chown postgres '{}' +
    find /var/run/postgresql \! -user postgres -exec chown postgres '{}' +
  fi
}

# initialize empty PGDATA directory with new database via 'initdb'
docker_init_database_dir() {
  local uid; uid="$(id -u)"
  if ! getent passwd "$uid" &> /dev/null; then
    local wrapper
    for wrapper in {/usr,}/lib{/*,}/libnss_wrapper.so; do
      if [ -s "$wrapper" ]; then
        NSS_WRAPPER_PASSWD="$(mktemp)"
        NSS_WRAPPER_GROUP="$(mktemp)"
        export LD_PRELOAD="$wrapper" NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
        local gid; gid="$(id -g)"
        printf 'postgres:x:%s:%s:PostgreSQL:%s:/bin/false\n' "$uid" "$gid" "$PGDATA" > "$NSS_WRAPPER_PASSWD"
        printf 'postgres:x:%s:\n' "$gid" > "$NSS_WRAPPER_GROUP"
        break
      fi
    done
  fi

  if [ -n "${POSTGRES_INITDB_WALDIR:-}" ]; then
    set -- --waldir "$POSTGRES_INITDB_WALDIR" "$@"
  fi

  eval 'initdb --username="$POSTGRES_USER" --pwfile=<(printf "%s\n" "$POSTGRES_PASSWORD") '"$POSTGRES_INITDB_ARGS"' "$@"'

  if [[ "${LD_PRELOAD:-}" == */libnss_wrapper.so ]]; then
    rm -f "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"
    unset LD_PRELOAD NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
  fi
}

# execute SQL via psql (socket-only)
docker_process_sql() {
  local query_runner=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password --no-psqlrc )
  if [ -n "$POSTGRES_DB" ]; then
    query_runner+=( --dbname "$POSTGRES_DB" )
  fi
  PGHOST= PGHOSTADDR= "${query_runner[@]}" "$@"
}

# create initial database if POSTGRES_DB != postgres and doesn't exist
docker_setup_db() {
  local dbAlreadyExists
  dbAlreadyExists="$(
    POSTGRES_DB= docker_process_sql --dbname postgres --set db="$POSTGRES_DB" --tuples-only <<-'EOSQL'
      SELECT 1 FROM pg_database WHERE datname = :'db' ;
EOSQL
  )"
  if [ -z "$dbAlreadyExists" ]; then
    POSTGRES_DB= docker_process_sql --dbname postgres --set db="$POSTGRES_DB" <<-'EOSQL'
      CREATE DATABASE :"db" ;
EOSQL
    printf '\n'
  fi
}

# load env and detect existing database
docker_setup_env() {
  file_env 'POSTGRES_PASSWORD'
  file_env 'POSTGRES_USER' 'postgres'
  file_env 'POSTGRES_DB' "$POSTGRES_USER"
  file_env 'POSTGRES_INITDB_ARGS'
  : "${POSTGRES_HOST_AUTH_METHOD:=}"

  declare -g DATABASE_ALREADY_EXISTS
  : "${DATABASE_ALREADY_EXISTS:=}"
  if [ -s "$PGDATA/PG_VERSION" ]; then
    DATABASE_ALREADY_EXISTS='true'
  fi
}

# append host auth method to pg_hba.conf
pg_setup_hba_conf() {
  if [ "$1" = 'postgres' ]; then
    shift
  fi
  local auth
  auth="$(postgres -C password_encryption "$@")"
  : "${POSTGRES_HOST_AUTH_METHOD:=$auth}"
  {
    printf '\n'
    if [ 'trust' = "$POSTGRES_HOST_AUTH_METHOD" ]; then
      printf '# warning trust is enabled for all connections\n'
      printf '# see https://www.postgresql.org/docs/current/auth-trust.html\n'
    fi
    printf 'host all all all %s\n' "$POSTGRES_HOST_AUTH_METHOD"
  } >> "$PGDATA/pg_hba.conf"
}

# start/stop temporary server on unix socket
docker_temp_server_start() {
  if [ "$1" = 'postgres' ]; then
    shift
  fi
  set -- "$@" -c listen_addresses='' -p "${PGPORT:-5432}"
  NOTIFY_SOCKET= \
  PGUSER="${PGUSER:-$POSTGRES_USER}" \
  pg_ctl -D "$PGDATA" -o "$(printf '%q ' "$@")" -w start
}

docker_temp_server_stop() {
  PGUSER="${PGUSER:-postgres}" pg_ctl -D "$PGDATA" -m fast -w stop
}

# process init files in /docker-entrypoint-initdb.d if any
docker_process_init_files() {
  printf '\n'
  local f
  for f; do
    case "$f" in
      *.sh)
        if [ -x "$f" ]; then
          printf '%s: running %s\n' "$0" "$f"; "$f"
        else
          printf '%s: sourcing %s\n' "$0" "$f"; . "$f"
        fi ;;
      *.sql)     printf '%s: running %s\n' "$0" "$f"; docker_process_sql -f "$f"; printf '\n' ;;
      *.sql.gz)  printf '%s: running %s\n' "$0" "$f"; gunzip -c "$f" | docker_process_sql; printf '\n' ;;
      *.sql.xz)  printf '%s: running %s\n' "$0" "$f"; xzcat "$f" | docker_process_sql; printf '\n' ;;
      *.sql.zst) printf '%s: running %s\n' "$0" "$f"; zstd -dc "$f" | docker_process_sql; printf '\n' ;;
      *)         printf '%s: ignoring %s\n' "$0" "$f" ;;
    esac
    printf '\n'
  done
}

# verify env
docker_verify_minimum_env() {
  if [ -z "$POSTGRES_PASSWORD" ] && [ 'trust' != "$POSTGRES_HOST_AUTH_METHOD" ]; then
    cat >&2 <<-'EOE'
Error: Database is uninitialized and superuser password is not specified.
       You must specify POSTGRES_PASSWORD to a non-empty value for the
       superuser (or set POSTGRES_HOST_AUTH_METHOD=trust for local dev only).
EOE
    exit 1
  fi
}

# Defaults
: "${PGDATA:=/var/lib/postgresql/data}"

main() {
  docker_setup_env
  docker_create_db_directories

  if [ "$(id -u)" = '0' ]; then
    exec gosu postgres "$BASH_SOURCE" "$@"
  fi

  if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
    docker_verify_minimum_env
    # ensure init scripts directory is listable to detect half-initialized state early
    ls /docker-entrypoint-initdb.d/ > /dev/null || :

    docker_init_database_dir
    pg_setup_hba_conf "$@"

    export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
    docker_temp_server_start "$@"

    docker_setup_db
    docker_process_init_files /docker-entrypoint-initdb.d/*

    docker_temp_server_stop
    unset PGPASSWORD

    printf '\nPostgreSQL init process complete; ready for start up.\n\n'
  else
    printf '\nPostgreSQL Database directory appears to contain a database; Skipping initialization\n\n'
  fi
}

main "$@"

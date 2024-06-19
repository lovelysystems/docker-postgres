#!/usr/bin/env bash
set -ex
declare -r DIR=$(cd "$(dirname "$0")" && pwd)
cd $DIR

# cleanup any previous run
docker-compose down --remove-orphans
rm -rf data
chmod 755 fill_db.sh

# start services in the background
docker-compose up -d

# wait for the server with version 12 to finish setup
docker-compose run --rm client wait_for_postgres

# stop the old db
docker-compose stop pg12

# run the upgrade
docker-compose run --rm upgrade

# start the new server
docker-compose up -d pg16

# wait for the new db server to start
docker-compose run --rm -e PGHOST=pg16 client wait_for_postgres

# vacuum the new database
docker-compose run --rm -e PGHOST=pg16 client vacuumdb --all --analyze-in-stages

# print version
docker-compose run --rm -e PGHOST=pg16 client psql -c 'SHOW server_version;'

docker-compose stop pg16

# Point-in-Time Recovery (PITR)

This example shows how to perform a Point-in-Time Recovery (PITR) using Barman. The example is based on
the [Barman documentation](https://docs.pgbarman.org/release/3.0.1/). The example assumes that you have
a running Postgres server and a Barman server. Postgres is configured to do backups via streaming protocol.
Barman is configured to do backups to a local directory that is mounted into the `backup` container.

The following steps need to be performed to restore a database to a specific point in time:

## Download full backup from s3

In order to roll back to specific point in time, we need to download the full backup from s3.

---
**IMPORTANT**

The earliest PITR for a given backup is the end of the base backup itself. If you want to recover 
at any point in time between the start and the end of a backup, you must use the previous backup.
---

1. Download + Extract the full base backup

```shell
# Sync the base backup from s3 
aws s3 sync s3://<BUCKET_NAME> s3_backup/ --exclude "*" --include "<S3_BASE_BACKUP_ID_PREFIX>"

# Extract the base backup tarball
mkdir -p s3_backup/<PATH_TO_BACKUP_ID>/data && tar xzf s3_backup/<PATH_TO_DATA_TAR_GZ> -C s3_backup/<PATH_TO_BACKUP_ID>/data

# Download the WAL files (only those that are needed for the recovery) 
aws s3 sync s3://<BUCKET_NAME> s3_backup/ --exclude "*" --include "<S3_WAL_PREFIX>"
```

2. Copy s3 backup to mounted barman home directory volume

```shell
sudo cp -r s3_backup/* ./volumes/barman/
```

## Start Barman server for local PITR

1. Start the barman server

```shell
docker-compose run --rm barman /bin/bash 
```

2. Recover the database to a specific point in time

```shell
barman rebuild-xlogdb pg
barman recover --target-time "2022-09-07 06:32:06.397252+00" pg 20220907T063126 ${PGDATA}
```

At the end of the execution of the recovery, the selected backup is recovered locally into the
mounted`pg_restore` volume and contains a data directory ready to be used to start a PostgreSQL instance.

# Incremental Backups

## Requires: BARMAN all green

```shell
$ barman cron
$ barman check pg
Server pg:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	backup minimum size: OK (25.5 MiB)
	wal maximum age: OK (no last_wal_maximum_age provided)
	wal size: OK (115.1 KiB)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 2 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archiver errors: OK
```

> NOTE: This command will force PostgreSQL to switch WAL file and trigger the archiving process in Barman.
>
> `barman switch-wal --force --archive pg # Troubleshoot: WAL archive: FAILED`

1. Create test data

```sql
sql> create table test (slno integer, ts timestamp);
sql> insert into test values (generate_series(1,1000),now());
```

2. First backup

```shell
$ barman backup --wait pg

$ barman list-backups pg
pg 20220907T063126 - Wed Sep  7 06:31:30 2022 - Size: 25.4 MiB - WAL Size: 0 B
```

3. Insert more data

```sql
sql> select now();
              now              
-------------------------------
 2022-09-07 06:32:06.397252+00

sql> insert into test values (generate_series(1001,2000),now());

sql> select now();
              now              
-------------------------------
 2022-09-07 06:32:30.457423+00
```

4. Simulate scheduled execution of WAL archiving operations

```shell
$ barman cron
```

5. Stop the Postgres server.

```shell
$ docker-compose stop postgres
```

6. Point-inTime Recovery (PITR)

At the end of the execution of the recovery, the selected backup is recovered locally and the destination path contains
a data directory ready to be used to start a PostgreSQL instance.

```shell
$ barman recover --target-time "2022-09-07 06:32:06.397252+00" pg 20220907T063126 ${PGDATA}
```

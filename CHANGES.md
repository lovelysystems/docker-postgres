# Changes for docker-postgres

## 2025-06-12 / 14.18.0

- upgrade postgres to 14.18
- multiplatform build with updated apgdiff

## 2023-08-23 / 14.9.0

### Feature

- update Postgres to version 14.9
- update `com.lovelysystems.gradle` to version 1.11.5
- enable passing custom options to apgdiff via `DIFFDB_APGDIFF_OPTIONS` env. var.

## 2023-01-11 / 14.6.0

- update postgres to version 14.6
- include barman cloud client in server image

## 2022-09-08 / 14.5.2

### Feature

- allow to configure slack notification if barman db server connection fails

## 2022-09-08 / 14.5.1

- allow to configure slack notification if barman backup fails

## 2022-09-08 / 14.5.0

### Feature

- update postgres to version 14.5
- allow to define barman backup schedule via environment variable
- Add `cron` to backup image

## 2022-09-07 / 14.1.1

### Feature

- upgraded postgres-plpython to version 14.5.1
- add `pg_hba` rule that allows users with role `replication` to use the PG streaming protocol.
- added `backup` docker image to allow disaster recovery using [Barman](https://pgbarman.org/). 

## 2021-12-27 / 14.1.0

### Feature

- upgraded to postgres 14.1
- made `wait_for_postgres` less verbose
- added `upgrade12` docker image to allow upgrading data directories from 12 to 14

### Breaking

- upgrade to 14 requires either a dump/restore or the
  [described update procedure](./examples/upgrading/upgrade_procedure.sh)

### Develop

- added tests and circleci setup

## 2021-12-17 / 12.9.0

### Feature

- upgraded to postgresql 12.9
- client: upgraded apgdiff to 0.0.2
- client: diffdb now does a 2-phase diff to allow cascading deletes and also validate the generated
  diff

### Breaking

- removed is_jsonb_valid extension, projects need to switch to
  https://github.com/lovelysystems/lovely-db-commons/tree/master/src/main/sql/microschema 


## 2021-11-02 / 12.8.0

### Feature

- base versions on postgres upstream version
- upgrade to postgres 12.8
- upgrade jsonschema and yaml python libs to most recent versions
- added python support on server along with yaml and json schema libs
- added client image with diff tool
- added debugger extension

## 2020-04-29 / 0.1.0

- Initial Release using Postgresql 12.2


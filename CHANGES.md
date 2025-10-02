# Changes for docker-postgres

## 2025-09-05 / 17.6.1

### Fix

- update to apgdiff 1.0.3

## 2025-09-05 / 17.6.0

### Feature

- upgrade to postgres 17.6-bookworm

## 2025-09-04 / 17.5.0

### Feature

- upgrade postgres to version 17
- remove image stage `upgrade12to16` for new builds

### Development

- update to gradle 8.14 and lovely plugin 1.16.0

## 2024-06-25 / 16.3.2

- bump apgdiff to 1.0.2 to make diffing actually work with pg 15+

## 2024-06-24 / 16.3.1

- bump apgdiff to 1.0.1 to make multiplatform builds work

## 2024-06-19 / 16.3.0

## Feature

- updated postgres to version 16.3
- added `upgrade12to16` stage to allow upgrading data directories from postgres version 12 to 16

### Develop

- upgrade gradle wrapper to version 8.6
- upgraded gradle plugin to fix docker push task

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

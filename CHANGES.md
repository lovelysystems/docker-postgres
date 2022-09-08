# Changes for docker-postgres

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


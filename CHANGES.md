# Changes for docker-postgres

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


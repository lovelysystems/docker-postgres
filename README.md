# Opinionated PostgreSQL Docker Images used at Lovely Systems

These images are derived from the [official postgres images](https://hub.docker.com/_/postgres) so
all tweaks from this image are available.

# Server Image

Installed extensions:

### [is_jsonb_valid](https://github.com/furstenheim/is_jsonb_valid)

Allows to validate jsonb data via json-schema

### [pldebugger](https://git.postgresql.org/gitweb/?p=pldebugger.git;a=tree)

Server-side support for debugging PL/pgSQL functions. Works with:

- [pgadmin](https://www.pgadmin.org/docs/pgadmin4/development/debugger.html)
- [dbeaver](https://github.com/dbeaver/dbeaver/wiki/PGDebugger#how-to-start-debug-with-local-breakpoint)

See the [Example Developer Compose Stack](./examples/pg_devsetup/docker-compose.yml) for details.

# Client Image

This docker image is used to initially generate and also to maintain the database schema for apps
deployed on postgres servers via psql.

Configuring the target database can be done via the known postgres environment variables.

## Schema location

Put sql files under `/app/schema/sql`, the init script runs `/app/schema/sql/init.sql`
using `/app/schema/sql`as orking directory.

## Initial creation of the Database

To initially create the vanilla schema of the app run:

```shell
init_schema
```

## Diff the Schema

In order to show the difference of the vanilla schema to the configured target database run:

```shell
diffdb
```

### Optional Environment Variables

#### `DIFFDB_DUMP_OPTIONS`

The options used by the `pg_dump` tool to extract what will be diffed. This can be overridden in
order to define the database to diff and to run a more specific diff

For example to run the diff just on the `gql` schema in the `app` db:

```shell
DIFFDB_DUMP_OPTIONS='-s -n gql -d app' diffdb
```

The diff is generated using the [apgdiff tool](https://github.com/lovelysystems/apgdiff) and prints
out the statements required to migrate the active db schema on the server to the vanilla schema.


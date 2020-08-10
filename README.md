# Opinionated PostgreSQL Docker Image used at Lovely Systems

Installed extensions:

### [is_jsonb_valid](https://github.com/furstenheim/is_jsonb_valid)

Allows to validate jsonb data via json-schema 

### [pldebugger](https://git.postgresql.org/gitweb/?p=pldebugger.git;a=tree)

Server-side support for debugging PL/pgSQL functions. Works with:
 
 - [pgadmin](https://www.pgadmin.org/docs/pgadmin4/development/debugger.html)
 - [dbeaver](https://github.com/dbeaver/dbeaver/wiki/PGDebugger#how-to-start-debug-with-local-breakpoint)

See the [Example Developer Compose Stack](./examples/pg_devsetup/docker-compose.yml) for details.

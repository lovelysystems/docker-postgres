FROM postgres:12.9 as base

# postgres sub-package versions are  nailed here is to ensure we build dev against the same version as installed
# the postgres vesions on http://apt.postgresql.org/pub/repos/apt/ might have changed since the last build
# if this version is not available anymore we need to use a different base image which btw might also change
# the debian distribution
ENV PG_APT_VERSION="12.9-1.pgdg110+1"

FROM base as extension_builder
RUN apt-get update
RUN apt-get install -y build-essential curl python3-pip && apt-get clean

COPY requirements.txt /tmp/
RUN mkdir /tmp/python-libs && \
    pip3 install --target /tmp/python-libs --disable-pip-version-check --no-deps -r /tmp/requirements.txt && \
    cd /tmp/python-libs && tar -czvf /python-libs.tgz . && \
    rm -rf /tmp/python-libs

FROM base as server

RUN apt-get update && apt-get install -y postgresql-12-pldebugger postgresql-plpython3-12=$PG_APT_VERSION && apt-get clean

COPY --from=extension_builder /python-libs.tgz /python-libs.tgz
RUN cd /usr/lib/python3.9 && tar -zxvf /python-libs.tgz

FROM server as client

RUN apt-get update && apt-get install -y less && apt-get clean

# get apgdiff tool to allow to diff the vanilla schema against target databases
COPY --from=lovelysystems/apgdiff:0.0.2 /usr/local/bin/apgdiff /usr/local/bin/

WORKDIR /app/
COPY psqlrc /root/.psqlrc

ENV PGHOST=${PGHOST:-127.0.0.1}
ENV PGUSER=${PGUSER:-postgres}

RUN chown -R postgres:postgres /app/

COPY ./lib/ /usr/local/lib/.
COPY ./bin/ /usr/local/bin/.
RUN chmod 755  /usr/local/bin/*

# options to use with pg_dump, to dump the vanilla schema
# the options to use for pg_dump, should be used to specify the database and optionally schemas
ENV DIFFDB_DUMP_OPTIONS=${DIFFDB_DUMP_OPTIONS:-'-s -d postgres'}

# the directory where the schema dir gets mounted. used by the init scripts
ENV SCHEMA_DIR=/app/schema

# override the entry point since we do not want to boostrap a server
ENTRYPOINT []
CMD ["psql"]


FROM server

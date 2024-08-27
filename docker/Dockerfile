FROM postgres:16.3-bullseye as base

# postgres sub-package versions are  nailed here is to ensure we build dev against the same version as installed
# the postgres vesions on http://apt.postgresql.org/pub/repos/apt/ might have changed since the last build
# if this version is not available anymore we need to use a different base image which btw might also change
# the debian distribution
ENV PG_APT_VERSION="16.4-1.pgdg120+1"

FROM base as extension_builder
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential curl python3-pip && apt-get clean

COPY requirements.txt /tmp/
RUN mkdir /tmp/python-libs && \
    pip3 install --target /tmp/python-libs --disable-pip-version-check --no-deps -r /tmp/requirements.txt && \
    cd /tmp/python-libs && tar -czvf /python-libs.tgz . && \
    rm -rf /tmp/python-libs

FROM base as server

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-16-pldebugger postgresql-plpython3-16=$PG_APT_VERSION barman-cli-cloud && \
    apt-get clean

COPY --from=extension_builder /python-libs.tgz /python-libs.tgz
RUN cd /usr/lib/python3.9 && tar -zxvf /python-libs.tgz
RUN echo "host replication replication all scram-sha-256" >> /usr/share/postgresql/16/pg_hba.conf.sample

FROM server as backup
COPY --from=lovelysystems/adminbox:0.4.2 /usr/bin/notify_if_fails /usr/bin/slack /usr/bin/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cron jq curl barman barman-cli && \
    apt-get clean

COPY psqlrc /root/.psqlrc

ENV PGHOST=${PGHOST:-127.0.0.1} \
    PGUSER=${PGUSER:-postgres}

WORKDIR /var/lib/barman
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["cron", "-f"]

FROM server as client

RUN apt-get update && apt-get install -y --no-install-recommends less && apt-get clean

# get apgdiff tool to allow to diff the vanilla schema against target databases
COPY --from=lovelysystems/apgdiff:1.0.2 /usr/local/bin/apgdiff /usr/local/bin/

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

# Stage to upgrade to this version from 12.x releases
# taken from https://github.com/tianon/docker-postgres-upgrade/blob/master/12-to-16/Dockerfile
FROM server as upgrade12to16
RUN sed -i 's/$/ 12/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-12=12.20-1.pgdg120+1 \
	&& rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/12/bin
ENV PGBINNEW /usr/lib/postgresql/16/bin

ENV PGDATAOLD /var/lib/postgresql/12/data
ENV PGDATANEW /var/lib/postgresql/16/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-upgrade

ENTRYPOINT ["docker-upgrade"]

CMD ["pg_upgrade"]

FROM server

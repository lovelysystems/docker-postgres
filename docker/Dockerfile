FROM postgres:14.0-bullseye as base

FROM base as extension_builder

RUN apt-get update
RUN apt-get install -y build-essential curl postgresql-server-dev-14

RUN mkdir /is_jsonb_valid
WORKDIR /is_jsonb_valid/
# master as of 2019-10-13
RUN curl -L 'https://github.com/furstenheim/is_jsonb_valid/tarball/5b4ab770f4070b8166f0dda3afb3287042b1b744' \
    | tar -xz --strip-components=1
RUN make clean install DESTDIR=/installation

RUN cd /installation && tar -czvf /extensions.tgz .

# The default stage
FROM base as server

RUN apt-get update && apt-get install -y postgresql-14-pldebugger &&  apt-get clean

COPY --from=extension_builder /extensions.tgz /extensions.tgz

RUN cd / && tar -zxvf extensions.tgz && rm extensions.tgz

# Stage to upgrade to this version from 12.x releases
# taken from https://github.com/tianon/docker-postgres-upgrade/blob/master/12-to-14/Dockerfile
FROM server as upgrade12
RUN sed -i 's/$/ 12/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-12=12.8-1.pgdg110+1 \
	&& rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/12/bin
ENV PGBINNEW /usr/lib/postgresql/14/bin

ENV PGDATAOLD /var/lib/postgresql/12/data
ENV PGDATANEW /var/lib/postgresql/14/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY --from=tianon/postgres-upgrade:12-to-14 /usr/local/bin/docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]

FROM server
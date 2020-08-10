ARG pg_version=12.2

FROM postgres:$pg_version as extension_builder

RUN apt-get update
RUN apt-get install -y build-essential curl libssl-dev libkrb5-dev
RUN apt-get install -y postgresql-server-dev-12

RUN mkdir /pldebugger
WORKDIR /pldebugger/
# use the snapshot link in the web ui to generate this link
# master as of 2020-08-10
RUN curl 'https://git.postgresql.org/gitweb/?p=pldebugger.git;a=snapshot;h=ddbce7be9c3ac782ca3369291c1772cbe413cf75;sf=tgz' \
    | tar -xz --strip-components=1
RUN USE_PGXS=1 make clean install DESTDIR=/installation

RUN mkdir /is_jsonb_valid
WORKDIR /is_jsonb_valid/
# master as of 2019-10-13
RUN curl -L 'https://github.com/furstenheim/is_jsonb_valid/tarball/41e1ad6572e1be8b514e86234f743fbe5682d21a' \
    | tar -xz --strip-components=1
RUN make clean install DESTDIR=/installation

RUN cd /installation && tar -czvf /extensions.tgz .

FROM postgres:$pg_version

COPY --from=extension_builder /extensions.tgz /extensions.tgz
RUN cd / && tar -zxvf extensions.tgz && rm extensions.tgz

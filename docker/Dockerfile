ARG pg_version=12.0

FROM postgres:$pg_version as is_jsonb_valid_build

RUN apt-get update -y
RUN apt-get install -y build-essential curl
RUN apt-get install -y postgresql-server-dev-12
RUN mkdir /project
WORKDIR /project/
# master as of 2019-10-13
RUN curl -L 'https://github.com/furstenheim/is_jsonb_valid/tarball/41e1ad6572e1be8b514e86234f743fbe5682d21a' \
    | tar -xz --strip-components=1
RUN find .
RUN make clean install DESTDIR=/installation
# RUN make installcheck
RUN find /installation
RUN cd /installation && tar -czvf /is_jsonb_valid.tgz .

FROM postgres:$pg_version

COPY --from=is_jsonb_valid_build /is_jsonb_valid.tgz /is_jsonb_valid.tgz
RUN cd / && tar -zxvf is_jsonb_valid.tgz && rm is_jsonb_valid.tgz


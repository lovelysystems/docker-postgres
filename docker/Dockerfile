FROM postgres:12.2 as base

FROM base as extension_builder

RUN apt-get update
RUN apt-get install -y build-essential curl postgresql-server-dev-12

RUN mkdir /is_jsonb_valid
WORKDIR /is_jsonb_valid/

RUN curl -L 'https://github.com/furstenheim/is_jsonb_valid/tarball/5b4ab770f4070b8166f0dda3afb3287042b1b744' \
    | tar -xz --strip-components=1
RUN make clean install DESTDIR=/installation

RUN cd /installation && tar -czvf /extensions.tgz .

FROM base

RUN apt-get update && apt-get install -y postgresql-12-pldebugger &&  apt-get clean

COPY --from=extension_builder /extensions.tgz /extensions.tgz

RUN cd / && tar -zxvf extensions.tgz && rm extensions.tgz


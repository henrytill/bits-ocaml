FROM alpine:3.14

ARG DEFAULT_SWITCH=4.14.1

RUN apk add --no-cache build-base m4 opam pkgconf sqlite-dev sqlite-static

RUN adduser -D build

USER build

WORKDIR /home/build

RUN opam init --disable-sandboxing --auto-setup -q && \
    opam switch create $DEFAULT_SWITCH && \
    opam switch set $DEFAULT_SWITCH

RUN opam install -yq delimcc ocamlfind sqlite3

RUN mkdir -p /home/build/ocaml-bits

COPY --chown=build:build . /home/build/ocaml-bits/

WORKDIR /home/build/ocaml-bits

RUN echo 'OCAMLOPTFLAGS += -ccopt -static' > config.mk

RUN opam config exec -- make

FROM alpine:3.20

ARG DEFAULT_SWITCH=ocaml-base-compiler.4.14.2

RUN apk add --no-cache build-base git m4 opam pkgconf sqlite-dev sqlite-static

RUN adduser -D build

USER build

WORKDIR /home/build

RUN opam init --disable-sandboxing --auto-setup -q -c $DEFAULT_SWITCH

RUN mkdir -p /home/build/bits-ocaml

WORKDIR /home/build/bits-ocaml

COPY --chown=build:build bits-ocaml.opam /home/build/bits-ocaml/

RUN opam install -yq . --deps-only --no-depexts

COPY --chown=build:build . /home/build/bits-ocaml/

RUN opam exec -- ./configure

RUN echo 'OCAMLOPTFLAGS += -ccopt -static' > config.mk

RUN opam exec -- make opt

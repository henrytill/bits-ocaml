#!/bin/sh

set -e

FILES="$@"
TAG=${TAG:-ocaml-bits:latest}
DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:-/home/build/ocaml-bits}

if [ -z "$FILES" ]; then
  echo "Usage: sh ${0} <file1> <file2> ..." >&2
  exit 1
fi

build() {
  docker build --tag "$1" --progress=plain "$(pwd)"
}

create() {
  docker create "$1"
}

copy() {
  echo "Copying ${2}"
  docker cp -q "${1}:${DOCKER_BUILD_DIR}/${2}" "$(pwd)/_static/${2}"
}

remove() {
  docker remove "$1" >/dev/null
}

build "$TAG"

cid="$(create "$TAG")"

mkdir -p _static/src
mkdir -p _static/test

for file in $FILES; do
  copy "$cid" "$file"
done

remove "$cid"

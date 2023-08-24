#!/bin/sh

set -e

FILES="$@"
TAG=${TAG:-ocaml-bits:latest}
DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:-/home/build/ocaml-bits}

if [ -z "$FILES" ]; then
    echo "Usage: ${0} <file1> <file2> ..."
    exit 1
fi

build () {
    docker build --tag "$1" --progress=plain "$(pwd)"
}

create() {
    docker create "$1"
}

copy() {
    docker cp -q "${1}:${DOCKER_BUILD_DIR}/${2}" "$(pwd)"
}

remove() {
    docker remove "$1"
}

check() {
    printf '\n'
    file "$1"
    ./"$1"
}

make clean

build "$TAG"

cid="$(create "$TAG")"

for file in $FILES; do
    copy "$cid" "$file"
done

remove "$cid"

for file in $FILES; do
    check "$file"
done

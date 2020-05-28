#!/bin/bash

sed_expr="s,^,opentrickler/,"
readonly version=$(head -n 1 VERSION)
out=opentrickler-${version}.tar

tar --create --transform "$sed_expr" --file $out \
  LICENSE \
  VERSION \
  README.md \
  .eslintrc.js \
  ecosystem.config.js \
  index.js \
  package.json \
  server.js \
  server.sh \
  lib/

xz -c $out > $out.xz

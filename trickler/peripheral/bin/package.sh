#!/bin/bash

sed_expr="s,^,opentrickler/,"
readonly version=$(head -n 1 VERSION)
out=opentrickler-${version}.tar

tar --create --transform "$sed_expr" --file $out \
  LICENSE \
  VERSION \
  README.md \
  MANIFEST.in \
  .pylintrc \
  setup.cfg \
  setup.py \
  opentrickler_config.ini \
  opentrickler_api.yaml \
  bluetooth.sh \
  leds.sh \
  server.sh \
  trickler/

xz -c $out > $out.xz

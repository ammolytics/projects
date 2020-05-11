#!/bin/sh

cd /code/opentrickler
exec ./server.js ecosystem.config.js >> "$1" 2>&1

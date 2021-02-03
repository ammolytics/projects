#!/bin/sh

cd /code/opentrickler
exec ./trickler/main.py config.ini >> "$1" 2>&1

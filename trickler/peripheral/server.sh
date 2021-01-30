#!/bin/sh

cd /code/opentrickler
exec ./trickler/main.py --config_file=config.ini >> "$1" 2>&1

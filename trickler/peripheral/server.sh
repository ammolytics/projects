#!/bin/sh

# Enter code directory and start the trickler daemon.
cd /code/opentrickler
exec ./trickler/main.py config.ini >> "$1" 2>&1

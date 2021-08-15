#!/bin/sh

cd /code/opentrickler
exec ./trickler/ble_v1.py opentrickler_config.ini >> "$1" 2>&1

#!/bin/sh

# Disable the usual trigger for built-in activity LED.
echo none | sudo tee /sys/class/leds/led0/trigger

# Enter code directory and start the trickler LED daemon.
cd /code/opentrickler
exec ./trickler/leds.py opentrickler_config.ini >> "$1" 2>&1

# Revert activity LED to original trigger.
#echo mmc0 | sudo tee /sys/class/leds/led0/trigger

#!/usr/bin/env python3
import serial
import datetime


scale = serial.Serial(port='/dev/ttyUSB0', baudrate=19200, timeout=0.05)

while 1:
    print(datetime.datetime.now().isoformat(), scale.readline())

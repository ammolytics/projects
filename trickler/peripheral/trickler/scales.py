#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import atexit
import decimal
import enum
import logging
import time

import serial


class Units(enum.Enum):
    GRAINS = 0
    GRAMS = 1


UNIT_MAP = {
    'GN': Units.GRAINS,
    'g': Units.GRAMS,
}


def noop(*args, **kwargs):
    """No-op function for scales to use on throwaway status updates."""
    return


class ANDFx120:
    """Class for controlling an A&D FX120 scale."""

    class ScaleStatus(enum.Enum):
        STABLE = 0
        UNSTABLE = 1
        OVERLOAD = 2
        ERROR = 3
        MODEL_NUMBER = 4
        SERIAL_NUMBER = 5
        ACKNOWLEDGE = 6

    def __init__(self, memcache, port='/dev/ttyUSB0', baudrate=19200, timeout=0.1, **kwargs):
        """Controller."""
        self._memcache = memcache
        self._serial = serial.Serial(port=port, baudrate=baudrate, timeout=timeout, **kwargs)
        # Set default values, which should be overwritten quickly.
        self.raw = b''
        self.unit = Units.GRAINS
        self.resolution = decimal.Decimal(0.02)
        self.weight = decimal.Decimal('0.00')
        self.status = self.ScaleStatus.STABLE
        self.model_number = None
        self.serial_number = None
        atexit.register(self._graceful_exit)

    def _graceful_exit(self):
        """Graceful exit, closes serial port."""
        logging.debug('Closing serial port...')
        self._serial.close()

    def change_unit(self):
        """Changes the unit of weight on the scale."""
        logging.debug('changing weight unit on scale from: %r', self.unit)
        # Send Mode button command.
        self._serial.write(b'U\r\n')
        self.update()

    @property
    def is_stable(self):
        """Returns True if the scale is stable, otherwise False."""
        return self.status == self.ScaleStatus.STABLE

    def update(self):
        """Read from the serial port and update an instance of this class with the most recent values."""
        handlers = {
            'ST': self._stable,
            'US': self._unstable,
            'OL': self._overload,
            'EC': self._error,
            'AK': self._acknowledge,
            'TN': self._model_number,
            'SN': self._serial_number,
            None: noop,
        }

        raw = self._serial.readline()
        self.raw = raw
        logging.debug(raw)
        try:
            line = raw.strip().decode('utf-8')
        except UnicodeDecodeError:
            logging.debug('Could not decode bytes to unicode.')
        else:
            status = line[0:2]
            handler = handlers.get(status, noop)
            handler(line)

    def _stable_unstable(self, line):
        """Update the scale when status is stable or unstable."""
        weight = line[3:12].strip()
        self.weight = decimal.Decimal(weight)

        unit = line[12:15].strip()
        self.unit = UNIT_MAP[unit]

        resolution = {}
        resolution[Units.GRAINS] = decimal.Decimal(0.02)
        resolution[Units.GRAMS] = decimal.Decimal(0.001)

        self.resolution = resolution[self.unit]
        # Update memcache values.
        self._memcache.set('scale_status', self.status)
        self._memcache.set('scale_weight', self.weight)
        self._memcache.set('scale_unit', self.unit)
        self._memcache.set('scale_resolution', self.resolution)

    def _stable(self, line):
        """Scale is stable."""
        self.status = self.ScaleStatus.STABLE
        self._stable_unstable(line)

    def _unstable(self, line):
        """Scale is unstable."""
        self.status = self.ScaleStatus.UNSTABLE
        self._stable_unstable(line)

    def _overload(self, line):
        """Scale is overloaded."""
        self.status = self.ScaleStatus.OVERLOAD
        self._memcache.set('scale_status', self.status)

    def _error(self, line):
        """Scale has an error."""
        self.status = self.ScaleStatus.ERROR
        self._memcache.set('scale_status', self.status)

    def _acknowledge(self, line):
        """Scale has acknowledged a command."""
        self.status = self.ScaleStatus.ACKNOWLEDGE
        self._memcache.set('scale_status', self.status)

    def _model_number(self, line):
        """Gets & sets the scale's model number."""
        self.status = self.ScaleStatus.MODEL_NUMBER
        self.model_number = line[3:]

    def _serial_number(self, line):
        """Gets & sets the scale's serial number."""
        self.status = self.ScaleStatus.SERIAL_NUMBER
        self.serial_number = line[3:]


SCALES = {
    'and-fx120': ANDFx120,
}


if __name__ == '__main__':
    import argparse

    import pymemcache.client.base
    import pymemcache.serde

    parser = argparse.ArgumentParser(description='Test scale.')
    parser.add_argument('--scale', choices=SCALES.keys(), default='and-fx120')
    parser.add_argument('--scale_port', default='/dev/ttyUSB0')
    parser.add_argument('--scale_baudrate', type=int, default='19200')
    parser.add_argument('--scale_timeout', type=float, default='0.1')
    args = parser.parse_args()

    memcache_client = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    scale = SCALES[args.scale](
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout,
        memcache=memcache_client)

    while 1:
        scale.update()

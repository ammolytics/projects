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

import serial # pylint: disable=import-error;

import constants


class Units(enum.Enum):
    GRAINS = 0
    GRAMS = 1


UNIT_MAP = {
    'GN': Units.GRAINS,
    'g': Units.GRAMS,
}


UNIT_REVERSE_MAP = {
    Units.GRAINS: 'GN',
    Units.GRAMS: 'g',
}


def noop(*args, **kwargs):
    """No-op function for scales to use on throwaway status updates."""
    return


class ANDFx120:
    """Class for controlling an A&D FX120 scale."""

    class ScaleStatusV1(enum.Enum):
        """Supports the first version of OpenTrickler software."""
        STABLE = 0
        UNSTABLE = 1
        OVERLOAD = 2
        ERROR = 3
        MODEL_NUMBER = 4
        SERIAL_NUMBER = 5
        ACKNOWLEDGE = 6

    class ScaleStatusV2(enum.Enum):
        """New version avoids zero (0) which can be confused with null/None."""
        STABLE = 1
        UNSTABLE = 2
        OVERLOAD = 3
        ERROR = 4
        MODEL_NUMBER = 5
        SERIAL_NUMBER = 6
        ACKNOWLEDGE = 7

    def __init__(self, memcache, port='/dev/ttyUSB0', baudrate=19200, timeout=0.1, _version=1, **kwargs):
        """Controller."""
        self._memcache = memcache
        self._serial = serial.Serial(port=port, baudrate=baudrate, timeout=timeout, **kwargs)
        # Set default values, which should be overwritten quickly.
        self.raw = b''
        self.unit = Units.GRAINS
        self.resolution = decimal.Decimal(0.02)
        self.weight = decimal.Decimal('0.00')

        self.StatusMap = self.ScaleStatusV1
        if _version == 2:
            self.StatusMap = self.ScaleStatusV2

        self.status = self.StatusMap.STABLE
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
        # Sleep 1s and wait for change to take effect.
        time.sleep(1)
        # Run update fn to set latest values.
        self.update()

    @property
    def is_stable(self):
        """Returns True if the scale is stable, otherwise False."""
        return self.status == self.StatusMap.STABLE

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

        # Note: The input buffer can fill up, causing latency. Clear it before reading.
        self._serial.reset_input_buffer()
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
        self._memcache.set(constants.SCALE_STATUS, self.status)
        self._memcache.set(constants.SCALE_WEIGHT, self.weight)
        self._memcache.set(constants.SCALE_UNIT, self.unit)
        self._memcache.set(constants.SCALE_RESOLUTION, self.resolution)
        self._memcache.set(constants.SCALE_IS_STABLE, self.is_stable)

    def _stable(self, line):
        """Scale is stable."""
        self.status = self.StatusMap.STABLE
        self._stable_unstable(line)

    def _unstable(self, line):
        """Scale is unstable."""
        self.status = self.StatusMap.UNSTABLE
        self._stable_unstable(line)

    def _overload(self, line):
        """Scale is overloaded."""
        self.status = self.StatusMap.OVERLOAD
        self._memcache.set(constants.SCALE_STATUS, self.status)

    def _error(self, line):
        """Scale has an error."""
        self.status = self.StatusMap.ERROR
        self._memcache.set(constants.SCALE_STATUS, self.status)

    def _acknowledge(self, line):
        """Scale has acknowledged a command."""
        self.status = self.StatusMap.ACKNOWLEDGE
        self._memcache.set(constants.SCALE_STATUS, self.status)

    def _model_number(self, line):
        """Gets & sets the scale's model number."""
        self.status = self.StatusMap.MODEL_NUMBER
        self.model_number = line[3:]

    def _serial_number(self, line):
        """Gets & sets the scale's serial number."""
        self.status = self.StatusMap.SERIAL_NUMBER
        self.serial_number = line[3:]


SCALES = {
    'and-fx120': ANDFx120,
}


if __name__ == '__main__':
    import argparse

    import helpers

    parser = argparse.ArgumentParser(description='Test scale.')
    parser.add_argument('--scale', choices=SCALES.keys(), default='and-fx120')
    parser.add_argument('--scale_port', default='/dev/ttyUSB0')
    parser.add_argument('--scale_baudrate', type=int, default='19200')
    parser.add_argument('--scale_timeout', type=float, default='0.1')
    parser.add_argument('--scale_version', type=int, default='1')
    args = parser.parse_args()

    memcache_client = helpers.get_mc_client()

    helpers.setup_logging()

    scale = SCALES[args.scale](
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout,
        memcache=memcache_client,
        _version=args.scale_version)

    while 1:
        scale.update()

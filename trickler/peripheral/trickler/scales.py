#!/usr/bin/env python3

import decimal
import enum
import logging
import time

import serial


class Units(enum.Enum):
    GRAINS = 0
    GRAMS = 1


class ScaleStatus(enum.Enum):
    STABLE = 0
    UNSTABLE = 1
    OVERLOAD = 2
    ERROR = 3
    MODEL_NUMBER = 4
    SERIAL_NUMBER = 5
    ACKNOWLEDGE = 6


class ANDFx120(object):

    def __init__(self, port='/dev/ttyUSB0', baudrate=19200, timeout=0.05, **kwargs):
        self.serial = serial.Serial(port=port, baudrate=baudrate, timeout=timeout, **kwargs)

    def change_unit(self, to_unit):
        # TODO(eric): prevent infinite loops.
        logging.debug('changing weight unit on scale from: %r to: %r', self.unit, to_unit)
        while self.unit != to_unit:
            # Send Mode button command.
            self.serial.write('U\r\n')
            time.sleep(0.1)
            self.update()

    def update(self):
        handlers = {
            'ST': self._stable,
            'US': self._unstable,
            'OL': self._overload,
            'EC': self._error,
            'AK': self._acknowledge,
            'TN': self._model_number,
            'SN': self._serial_number,
            None: self._noop,
        }

        raw = self.serial.readline()
        self.raw = raw
        logging.debug(raw)
        line = raw.strip().decode('utf-8')
        status = line[0:2]
        handler = handlers.get(status, self._noop)
        handler(line)

    def _stable_unstable(self, line):
        weight = line[3:12].strip()
        self.weight = decimal.Decimal(weight)

        units = {
            'GN': Units.GRAINS,
            'g': Units.GRAMS,
        }
        unit = line[12:15].strip()
        self.unit = units[unit]

        resolution = {}
        resolution[Units.GRAINS] = decimal.Decimal(0.02)
        resolution[Units.GRAMS] = decimal.Decimal(0.001)
       
        self.resolution = resolution[self.unit]

    def _stable(self, line):
        self.status = ScaleStatus.STABLE
        self._stable_unstable(line)

    def _unstable(self, line):
        self.status = ScaleStatus.UNSTABLE
        self._stable_unstable(line)

    def _overload(self, line):
        self.status = ScaleStatus.OVERLOAD

    def _error(self, line):
        self.status = ScaleStatus.ERROR

    def _acknowledge(self, line):
        self.status = ScaleStatus.ACKNOWLEDGE

    def _model_number(self, line):
        self.status = ScaleStatus.MODEL_NUMBER
        self.model = line[3:]

    def _serial_number(self, line):
        self.status = ScaleStatus.SERIAL_NUMBER
        self.serial = line[3:]

    def _noop(self, line):
        pass


SCALES = {
  'and-fx120': ANDFx120,
}


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Test scale.')
    parser.add_argument('--scale', choices=SCALES.keys(), default='and-fx120')
    parser.add_argument('--scale_port', default='/dev/ttyUSB0')
    parser.add_argument('--scale_baudrate', type=int, default='19200')
    parser.add_argument('--scale_timeout', type=float, default='0.05')
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    scale = SCALES[args.scale](
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout)

    while 1:
        scale.update()

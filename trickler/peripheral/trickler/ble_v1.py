#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import atexit
import functools
import logging
import os
import time

import pybleno # pylint: disable=import-error;

import constants
import helpers
import scales


TRICKLER_UUID = '10000000-be5f-4b43-a49f-76f2d65c6e28'


class BasicCharacteristic(pybleno.Characteristic):

    def __init__(self, *args, **kwargs):
        super(BasicCharacteristic, self).__init__(*args, **kwargs)
        self._memcache = None
        self._mc_key = None
        self._updateValueCallback = None
        self._send_fn = helpers.noop
        self._recv_fn = helpers.noop
        self.__value = None

    def onSubscribe(self, maxValueSize, updateValueCallback):
        self._maxValueSize = maxValueSize
        self._updateValueCallback = updateValueCallback

    def onUnsubscribe(self):
        self._maxValueSize = None
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = self._send_fn(self.mc_value) # pylint: disable=assignment-from-none;
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    @property
    def mc_value(self):
        return self.__value

    @mc_value.setter
    def mc_value(self, value):
        if value == self.__value:
            return
        logging.info('Updating %s: from %r to %r', self._mc_key, self.__value, value)
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(self._send_fn(self.__value))

    def mc_get(self):
        for _ in range(2):
            try:
                value = self._memcache.get(self._mc_key)
            except (KeyError, ValueError):
                logging.exception('Cache miss.')
            else:
                return value

    def mc_update(self):
        value = self.mc_get()
        self.mc_value = value


class AutoMode(BasicCharacteristic):

    def __init__(self, memcache):
        super(AutoMode, self).__init__({
            'uuid': '10000005-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'write'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Start/stop automatic trickle mode'
                ))],
            'value': False,
        })
        self._memcache = memcache
        self._mc_key = constants.AUTO_MODE
        self._updateValueCallback = None
        self._send_fn = helpers.bool_to_bytes
        self._recv_fn = helpers.bytes_to_bool
        self.__value = self.mc_get()

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = self._recv_fn(data)
            logging.info('Changing %s to %r', self._mc_key, value)
            self._memcache.set(self._mc_key, value)
            # This will notify subscribers.
            self.mc_value = value
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleStatus(BasicCharacteristic):

    def __init__(self, memcache):
        super(ScaleStatus, self).__init__({
            'uuid': '10000002-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current stability status of the scale'
                ))],
        })
        self._memcache = memcache
        self._mc_key = constants.SCALE_STATUS
        self._updateValueCallback = None
        self._send_fn = helpers.enum_to_bytes
        self._recv_fn = helpers.bytes_to_enum
        self.__value = self.mc_get()


class TargetWeight(BasicCharacteristic):

    def __init__(self, memcache):
        super(TargetWeight, self).__init__({
            'uuid': '10000004-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'write'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Target powder weight'
                ))],
        })
        self._memcache = memcache
        self._mc_key = constants.TARGET_WEIGHT
        self._updateValueCallback = None
        self._send_fn = helpers.decimal_to_bytes
        self._recv_fn = helpers.bytes_to_decimal
        self.__value = self.mc_get()

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) == 0:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = self._recv_fn(data)
            logging.info('Changing %s to %r', self._mc_key, value)
            self._memcache.set(self._mc_key, value)
            # This will notify subscribers.
            self.mc_value = value
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleUnit(BasicCharacteristic):

    def __init__(self, memcache):
        super(ScaleUnit, self).__init__({
            'uuid': '10000003-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'write', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current weight unit of the scale'
                ))],
        })
        self._memcache = memcache
        self._mc_key = constants.SCALE_UNIT
        self._updateValueCallback = None
        self._send_fn = helpers.enum_to_bytes
        self._recv_fn = functools.partial(helpers.bytes_to_enum, scales.Units)
        self.__value = self.mc_get()

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = self._recv_fn(data)
            logging.info('Changing %s to %r', constants.TARGET_UNIT, value)
            # NOTE: Cannot set the scale unit directly, but can change the target unit.
            self._memcache.set(constants.TARGET_UNIT, value)
            # Notify subscribers.
            if self._updateValueCallback:
                self._updateValueCallback(data)
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleWeight(BasicCharacteristic):

    def __init__(self, memcache):
        super(ScaleWeight, self).__init__({
            'uuid': '10000001-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current weight value of the scale'
                ))],
        })
        self._memcache = memcache
        self._mc_key = constants.SCALE_WEIGHT
        self._updateValueCallback = None
        self._send_fn = helpers.decimal_to_bytes
        self._recv_fn = helpers.bytes_to_decimal
        self.__value = self.mc_get()


class TricklerService(pybleno.BlenoPrimaryService):

    def __init__(self, memcache):
        super(TricklerService, self).__init__({
            'uuid': TRICKLER_UUID,
            'characteristics': [
                AutoMode(memcache),
                ScaleStatus(memcache),
                ScaleUnit(memcache),
                ScaleWeight(memcache),
                TargetWeight(memcache),
            ],
        })

    def all_mc_update(self):
        for characteristic in self['characteristics']:
            characteristic.mc_update()


def error_handler(error):
    if error:
        logging.error(error)


def on_state_change(device_name, bleno, trickler_service, state):
    if state == 'poweredOn':
        bleno.startAdvertising(device_name, [TRICKLER_UUID], error_handler)
    else:
        bleno.stopAdvertising()


def on_advertising_start(bleno, trickler_service, error):
    if error:
        logging.error(error)
    else:
        logging.info('Starting advertising')
        bleno.setServices([trickler_service])


def on_advertising_stop():
    logging.info('Stopping advertising')


def on_accept(client_address):
    logging.info('Client connected: %r', client_address)


def on_disconnect(client_address):
    logging.info('Client disconnected: %r', client_address)


def graceful_exit(bleno):
    bleno.stopAdvertising()
    bleno.disconnect()
    logging.info('Stopping OpenTrickler Bluetooth...')


def all_variables_set(memcache):
    variables = (
        memcache.get(constants.AUTO_MODE, None) != None,
        memcache.get(constants.SCALE_STATUS, None) != None,
        memcache.get(constants.SCALE_WEIGHT, None) != None,
        memcache.get(constants.SCALE_UNIT, None) != None,
        memcache.get(constants.TARGET_WEIGHT, None) != None,
        memcache.get(constants.TARGET_UNIT, None) != None,
    )
    logging.info('Variables: %r', variables)
    return all(variables)


def run(config, args):
    memcache = helpers.get_mc_client()

    logging.info('Setting up Bluetooth...')
    trickler_service = TricklerService(memcache)
    device_name = config['bluetooth']['name']
    os.environ['BLENO_DEVICE_NAME'] = device_name
    logging.info('Bluetooth device will be advertised as %s', device_name)
    bleno = pybleno.Bleno()
    atexit.register(functools.partial(graceful_exit, bleno))

    # pylint: disable=no-member
    bleno.on('stateChange', functools.partial(on_state_change, device_name, bleno, trickler_service))
    bleno.on('advertisingStart', functools.partial(on_advertising_start, bleno, trickler_service))
    bleno.on('advertisingStop', on_advertising_stop)
    bleno.on('accept', on_accept)
    bleno.on('disconnect', on_disconnect)
    # pylint: enable=no-member

    logging.info('Checking if ready to advertise...')
    while 1:
        if all_variables_set(memcache):
            logging.info('Ready to advertise!')
            break
        time.sleep(0.1)

    logging.info('Advertising OpenTrickler over Bluetooth...')
    bleno.start()

    logging.info('Starting OpenTrickler Bluetooth daemon...')
    # Loop and keep TricklerService property values up to date from memcache.
    while 1:
        try:
            trickler_service.all_mc_update()
        except (AttributeError, OSError):
            logging.exception('Caught possible bluetooth exception.')
        time.sleep(0.1)

    logging.info('Stopping bluetooth daemon...')


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Test bluetooth')
    parser.add_argument('config_file')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(open(args.config_file))

    log_level = logging.INFO
    if config['general'].getboolean('verbose'):
        log_level = logging.DEBUG

    helpers.setup_logging(log_level)

    run(config, args)

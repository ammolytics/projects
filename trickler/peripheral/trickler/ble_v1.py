#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import array
import atexit
import functools
import logging

import pybleno

import helpers


TRICKLER_UUID = '10000000-be5f-4b43-a49f-76f2d65c6e28'


class BasicCharacteristic(pybleno.Characteristic):

    def onSubscribe(self, maxValueSize, updateValueCallback):
        self._maxValueSize = maxValueSize
        self._updateValueCallback = updateValueCallback

    def onUnsubscribe(self):
        self._maxValueSize = None
        self._updateValueCallback = None


class AutoMode(BasicCharacteristic):

    def __init__(self, memcache):
        BasicCharacteristic.__init__(self, {
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
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = array.array('B', [0] * 1)
            pybleno.writeUInt8(data, self._memcache.get('auto_mode'), 0)
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = pybleno.readUInt16BE(data, 0)
            # TODO: Validate value.
            self._memcache.set('auto_mode', value)
            # Notify subscribers.
            if self._updateValueCallback:
                self._updateValueCallback(value)
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleStatus(BasicCharacteristic):

    def __init__(self, memcache):
        BasicCharacteristic.__init__(self, {
            'uuid': '10000002-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current stability status of the scale'
                ))],
        })
        self._memcache = memcache
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = array.array('B', [0] * 1)
            pybleno.writeUInt8(data, self._memcache.get('scale_status'), 0)
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)


class TargetWeight(BasicCharacteristic):

    def __init__(self, memcache):
        BasicCharacteristic.__init__(self, {
            'uuid': '10000004-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'write'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Target powder weight'
                ))],
        })
        self._memcache = memcache
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            target_weight = self._memcache.get('target_weight')
            # TODO: Convert to number?
            data = array.array('B', [0] * len(target_weight))
            data.fromunicode(target_weight)
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) == 0:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = data.decode('utf-8')
            # TODO: Validate value.
            self._memcache.set('target_weight', value)
            # Notify subscribers.
            if self._updateValueCallback:
                self._updateValueCallback(value)
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleUnit(BasicCharacteristic):

    def __init__(self, memcache):
        BasicCharacteristic.__init__(self, {
            'uuid': '10000003-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'write', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current weight unit of the scale'
                ))],
        })
        self._memcache = memcache
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = array.array('B', [0] * 1)
            pybleno.writeUInt8(data, self._memcache.get('scale_unit'), 0)
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = pybleno.readUInt8(data, 0)
            # TODO: Validate value.
            # NOTE: Cannot set the scale unit directly, but can change the target unit.
            self._memcache.set('target_unit', value)
            # Notify subscribers.
            if self._updateValueCallback:
                self._updateValueCallback(value)
            callback(pybleno.Characteristic.RESULT_SUCCESS)


class ScaleWeight(BasicCharacteristic):

    def __init__(self, memcache):
        BasicCharacteristic.__init__(self, {
            'uuid': '10000001-be5f-4b43-a49f-76f2d65c6e28',
            'properties': ['read', 'notify'],
            'descriptors': [
                pybleno.Descriptor(dict(
                    uuid='2901',
                    value='Reads the current weight value of the scale'
                ))],
        })
        self._memcache = memcache
        self._updateValueCallback = None

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            scale_weight = self._memcache.get('scale_weight')
            # TODO: Convert to number?
            data = array.array('B', [0] * len(scale_weight))
            data.fromunicode(scale_weight)
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)


class TricklerService(pybleno.BlenoPrimaryService):

    def __init__(self, memcache):
        pybleno.BlenoPrimaryService.__init__(self, {
            'uuid': TRICKLER_UUID,
            'characteristics': [
                AutoMode(memcache),
                ScaleStatus(memcache),
                TargetWeight(memcache),
                ScaleUnit(memcache),
                ScaleWeight(memcache),
            ],
        })


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
        bleno.setServices([trickler_service])


def graceful_exit(bleno):
    bleno.stopAdvertising()
    bleno.disconnect()
    logging.info('Stopping OpenTrickler Bluetooth...')


def run(config, args):
    memcache = helpers.get_mc_client()

    logging.info('Setting up Bluetooth...')
    trickler_service = TricklerService(memcache)
    bleno = pybleno.Bleno()
    device_name = config['bluetooth']['name']
    atexit.register(functools.partial(graceful_exit, bleno))

    bleno.on('stateChange', functools.partial(on_state_change, device_name, bleno, trickler_service))
    bleno.on('advertisingStart', functools.partial(on_advertising_start, bleno, trickler_service))

    logging.info('Advertising OpenTrickler over Bluetooth...')
    bleno.start()

    logging.info('Starting OpenTrickler Bluetooth daemon...')
    while 1:
        pass

    logging.info('OpenTrickler Bluetooth daemon has stopped.')


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Test bluetooth')
    parser.add_argument('config_file')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(open(args.config_file))

    helpers.setup_logging()

    run(config, args)

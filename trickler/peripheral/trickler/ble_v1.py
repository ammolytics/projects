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

import pybleno


# TODO: Get from env.
DEVICE_NAME = 'Trickler'
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
                pybleno.Descriptor(
                    uuid = '2901',
                    value = 'Start/stop automatic trickle mode'
                )],
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
                pybleno.Descriptor(
                    uuid = '2901',
                    value = 'Reads the current stability status of the scale'
                )],
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
                pybleno.Descriptor(
                    uuid = '2901',
                    value = 'Target powder weight'
                )],
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
                pybleno.Descriptor(
                    uuid = '2901',
                    value = 'Reads the current weight unit of the scale'
                )],
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
                pybleno.Descriptor(
                    uuid = '2901',
                    value = 'Reads the current weight value of the scale'
                )],
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


def on_state_change(bleno, trickler_service, state):
    if state == 'poweredOn':
        bleno.startAdvertising(DEVICE_NAME, [TRICKLER_UUID], error_handler)
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


def run(memcache):
    trickler_service = TricklerService(memcache)
    bleno = pybleno.Bleno()
    atexit.register(functools.partial(graceful_exit, bleno))
    bleno.on('stateChange', functools.partial(on_state_change, bleno, trickler_service))
    bleno.on('advertisingStart', functools.partial(on_advertising_start, bleno, trickler_service))
    bleno.start()


if __name__ == '__main__':
    import argparse

    import pymemcache.client.base
    import pymemcache.serde

    parser = argparse.ArgumentParser(description='Test bluetooth')
    args = parser.parse_args()

    memcache_client = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    run(memcache_client)

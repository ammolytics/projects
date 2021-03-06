#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import array
import atexit
import decimal
import functools
import logging
import time

import pybleno

import constants
import helpers
import scales


TRICKLER_UUID = '10000000-be5f-4b43-a49f-76f2d65c6e28'


def bool_to_bytes(value):
    data_bytes = array.array('B', [0] * 1)
    pybleno.writeUInt8(data_bytes, value, 0)
    return data_bytes


def bytes_to_bool(data_bytes):
    value = pybleno.readUInt8(data_bytes, 0)
    return bool(value)


def str_to_bytes(value):
    data_bytes = array.array('B', [])
    data_bytes.frombytes(value.encode('utf-8'))
    return data_bytes


def bytes_to_str(data_bytes):
    return data_bytes.decode('utf-8')


def decimal_to_bytes(value):
    value = str(value)
    return str_to_bytes(value)


def bytes_to_decimal(data_bytes):
    value = bytes_to_str(data_bytes)
    return decimal.Decimal(value)


def enum_to_bytes(value_enum):
    data_bytes = array.array('B', [0] * 1)
    pybleno.writeUInt8(data_bytes, value_enum.value, 0)
    return data_bytes


def bytes_to_enum(data_bytes, enum_cls):
    value = pybleno.readUInt8(data_bytes, 0)
    return enum_cls(value)


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
        self.__value = self._memcache.get(constants.AUTO_MODE)

    @property
    def value(self):
        return self.__value

    @value.setter
    def value(self, value):
        if value == self.__value:
            return
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(bool_to_bytes(self.__value))

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = bool_to_bytes(self._memcache.get(constants.AUTO_MODE))
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = bytes_to_bool(data)
            self._memcache.set(constants.AUTO_MODE, value)
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
        self.__value = self._memcache.get(constants.SCALE_STATUS)

    @property
    def value(self):
        return self.__value

    @value.setter
    def value(self, value):
        if value == self.__value:
            return
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(enum_to_bytes(self.__value))

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = enum_to_bytes(self._memcache.get(constants.SCALE_STATUS))
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
        self.__value = self._memcache.get(constants.TARGET_WEIGHT)

    @property
    def value(self):
        return self.__value

    @value.setter
    def value(self, value):
        if value == self.__value:
            return
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(decimal_to_bytes(self.__value))

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = decimal_to_bytes(self._memcache.get(constants.TARGET_WEIGHT))
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) == 0:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = bytes_to_decimal(data)
            self._memcache.set(constants.TARGET_WEIGHT, value)
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
        self.__value = self._memcache.get(constants.SCALE_UNIT)

    @property
    def value(self):
        return self.__value

    @value.setter
    def value(self, value):
        if value == self.__value:
            return
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(enum_to_bytes(self.__value))

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = enum_to_bytes(self._memcache.get(constants.SCALE_UNIT))
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG)
        elif len(data) != 1:
            callback(pybleno.Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH)
        else:
            value = bytes_to_enum(data, scales.Units)
            # NOTE: Cannot set the scale unit directly, but can change the target unit.
            self._memcache.set(constants.TARGET_UNIT, value)
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
        self.__value = self._memcache.get(constants.SCALE_WEIGHT)

    @property
    def value(self):
        return self.__value

    @value.setter
    def value(self, value):
        if value == self.__value:
            return
        self.__value = value
        if self._updateValueCallback:
            self._updateValueCallback(decimal_to_bytes(self.__value))

    def onReadRequest(self, offset, callback):
        if offset:
            callback(pybleno.Characteristic.RESULT_ATTR_NOT_LONG, None)
        else:
            data = decimal_to_bytes(self._memcache.get(constants.SCALE_WEIGHT))
            callback(pybleno.Characteristic.RESULT_SUCCESS, data)


class TricklerService(pybleno.BlenoPrimaryService):

    def __init__(self, memcache):
        self.char_map = {
            constants.AUTO_MODE: AutoMode(memcache),
            constants.SCALE_STATUS: ScaleStatus(memcache),
            constants.SCALE_UNIT: ScaleUnit(memcache),
            constants.SCALE_WEIGHT: ScaleWeight(memcache),
            constants.TARGET_WEIGHT: TargetWeight(memcache),
        }
        logging.info('char_map: %r', self.char_map)

        pybleno.BlenoPrimaryService.__init__(self, {
            'uuid': TRICKLER_UUID,
            'characteristics': [self.char_map[k] for k in  self.char_map],
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


def run(config, args):
    memcache = helpers.get_mc_client()

    # TODO(eric): Push the following into a separate function with a try/catch so it can restart because pybleno is flaky.
    logging.info('Setting up Bluetooth...')
    trickler_service = TricklerService(memcache)
    bleno = pybleno.Bleno()
    device_name = config['bluetooth']['name']
    logging.info('Bluetooth device will be advertised as %s', device_name)
    atexit.register(functools.partial(graceful_exit, bleno))

    bleno.on('stateChange', functools.partial(on_state_change, device_name, bleno, trickler_service))
    bleno.on('advertisingStart', functools.partial(on_advertising_start, bleno, trickler_service))
    bleno.on('advertisingStop', on_advertising_stop)
    bleno.on('accept', on_accept)
    bleno.on('disconnect', on_disconnect)

    logging.info('Checking if ready to advertise...')
    while 1:
        variables = (
            memcache.get(constants.AUTO_MODE, None) != None,
            memcache.get(constants.SCALE_STATUS, None) != None,
            memcache.get(constants.SCALE_WEIGHT, None) != None,
            memcache.get(constants.SCALE_UNIT, None) != None,
            memcache.get(constants.TARGET_WEIGHT, None) != None,
        )
        logging.info('Variables: %r', variables)
        if all(variables):
            break

    logging.info('Advertising OpenTrickler over Bluetooth...')
    bleno.start()

    logging.info('Starting OpenTrickler Bluetooth daemon...')

    while 1:
        trickler_service.char_map.get(constants.SCALE_STATUS).value = memcache.get(constants.SCALE_STATUS)
        trickler_service.char_map.get(constants.SCALE_WEIGHT).value = memcache.get(constants.SCALE_WEIGHT)
        trickler_service.char_map.get(constants.SCALE_UNIT).value = memcache.get(constants.SCALE_UNIT)
        # TODO(eric): Disabled because these properties aren't configured to notify.
        #trickler_service.char_map.get(constants.AUTO_MODE).value = memcache.get(constants.AUTO_MODE)
        #trickler_service.char_map.get(constants.TARGET_WEIGHT).value = memcache.get(constants.TARGET_WEIGHT)
        time.sleep(0.1)

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

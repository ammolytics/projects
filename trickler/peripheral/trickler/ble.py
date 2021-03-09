#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import logging

import bluezero # pylint: disable=import-error;

import helpers


TRICKLER_UUID = '10000000-be5f-4b43-a49f-76f2d65c6e28'
AUTO_MODE_UUID = '10000005-be5f-4b43-a49f-76f2d65c6e28'
SCALE_STATUS_UUID = '10000002-be5f-4b43-a49f-76f2d65c6e28'
TARGET_WEIGHT_UUID = '10000004-be5f-4b43-a49f-76f2d65c6e28'
SCALE_UNIT_UUID = '10000003-be5f-4b43-a49f-76f2d65c6e28'
SCALE_WEIGHT_UUID = '10000001-be5f-4b43-a49f-76f2d65c6e28'


CHARACTERISTICS = dict(
    auto_mode=dict(
        uuid=AUTO_MODE_UUID,
        flags=['read', 'write'],
        description='Start/stop automatic trickle mode',
    ),
    target_weight=dict(
        uuid=TARGET_WEIGHT_UUID,
        flags=['read', 'write'],
        description='Target powder weight',
    ),
    scale_status=dict(
        uuid=SCALE_STATUS_UUID,
        flags=['read', 'notify'],
        description='Reads the current stability status of the scale',
    ),
    scale_unit=dict(
        uuid=SCALE_UNIT_UUID,
        flags=['read', 'write', 'notify'],
        description='Reads the current weight unit of the scale',
    ),
    scale_weight=dict(
        uuid=SCALE_WEIGHT_UUID,
        flags=['read', 'notify'],
        description='Reads the current weight value of the scale',
    ),
)


def graceful_exit():
    logging.info('Stopping OpenTrickler Bluetooth...')
    pass


def main(config, args):
    memcache = helpers.get_mc_client()

    adapters = list(bluezero.adapter.Adapter.available())
    logging.info('Available bluetooth adapters: %s', adapters)

    adapter_address = adapters[0].address
    logging.info('First adapter address: %s', adapter_address)

    device_name = config['bluetooth']['name']
    opentrickler = bluezero.peripheral.Peripheral(adapter_address, local_name=device_name)

    #atexit.register(functools.partial(graceful_exit, bleno))
    opentrickler.add_service(srv_id=1, uuid=TRICKLER_UUID, primary=True)
    for i, key, char in enumerate(CHARACTERISTICS.items(), start=1):
        char['srv_id'] = 1
        char['chr_id'] = i
        char['notifying'] = 'notify' in char['flags']
        opentrickler.add_characteristic(**char)

    opentrickler.publish()


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Test bluetooth')
    parser.add_argument('config_file')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(open(args.config_file))

    helpers.setup_logging()

    main(config, args)

#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import atexit
import enum
import logging
import time

import gpiozero # pylint: disable=import-error;

import constants
import helpers


class TricklerStatus(enum.Enum):
    """The tuple values correspond to auto_mode, motor_on."""
    READY = (False, False)
    RUNNING = (True, True)
    DONE = (True, False)


STATUS_MAP = {
    TricklerStatus.READY: 'ready_status_led_mode',
    TricklerStatus.RUNNING: 'running_status_led_mode',
    TricklerStatus.DONE: 'done_status_led_mode',
}


def led_fast_blink(led):
    led.blink(on_time=0.75, off_time=0.75)


def led_slow_blink(led):
    led.blink(on_time=1.5, off_time=1.5)


def led_off(led):
    led.off()


def led_on(led):
    led.on()


def led_pulse(led):
    led.pulse()


LED_MODES = {
    'fast_blink': led_fast_blink,
    'off': led_off,
    'on': led_on,
    'pulse': led_pulse,
    'slow_blink': led_slow_blink,
}


def all_variables_set(memcache):
    variables = (
        memcache.get(constants.AUTO_MODE, None) != None,
        memcache.get(constants.TRICKLER_MOTOR_SPEED, None) != None,
    )
    logging.info('Variables: %r', variables)
    return all(variables)


def run(config, args):
    memcache = helpers.get_mc_client()

    status_led_pin = int(config['leds']['status_led_pin'])
    status_led = gpiozero.PWMLED(status_led_pin, active_high=config['leds'].getboolean('active_high', True))
    last_led_fn = None

    logging.info('Checking if ready to begin...')
    while 1:
        if all_variables_set(memcache):
            logging.info('Ready!')
            break
        time.sleep(0.1)

    while 1:
        try:
            motor_on = float(memcache.get(constants.TRICKLER_MOTOR_SPEED, 0.0)) > 0
            auto_mode = memcache.get(constants.AUTO_MODE)
        except (KeyError, ValueError):
            logging.exception('Possible cache miss, trying again.')
            break

        try:
            status = TricklerStatus((auto_mode, motor_on))
        except ValueError:
            logging.info('Bad state. auto_mode:%r and motor_on:%r', auto_mode, motor_on)
            break

        led_fn = LED_MODES.get(config['leds'][STATUS_MAP[status]])
        if led_fn != last_led_fn:
            led_fn(status_led)
            last_led_fn = led_fn
        time.sleep(1)


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

    if config['leds'].getboolean('enable_status_leds'):
        run(config, args)

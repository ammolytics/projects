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

import gpiozero

import constants
import helpers


class TricklerStatus(enum.Enum):
    READY = (True, False)
    RUNNING = (True, True)
    STOPPED = (False, False)


STATUS_MAP = {
    TricklerStatus.READY: 'ready_status_led_mode',
    TricklerStatus.RUNNING: 'running_status_led_mode',
    TricklerStatus.STOPPED: 'stopped_status_led_mode',
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


def run(config, args):
    memcache = helpers.get_mc_client()

    status_led_pin = int(config['leds']['status_led_pin'])
    status_led = gpiozero.PWMLED(status_led_pin)

    while 1:
        motor_on = float(memcache.get(constants.TRICKLER_MOTOR_SPEED)) > 0
        auto_mode = memcache.get(constants.AUTO_MODE)
        status = TricklerStatus((auto_mode, motor_on))

        led_fn = LED_MODES.get(config['leds'][STATUS_MAP[status]])
        led_fn(status_led)


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Test bluetooth')
    parser.add_argument('config_file')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(open(args.config_file))

    helpers.setup_logging()

    if config['leds'].getboolean('enable_status_leds'):
        run(config, args)

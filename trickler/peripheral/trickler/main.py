#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import datetime
import decimal
import logging
import time

import helpers
import PID
import motors
import scales


# Components:
# 0. Server (Pi)
# 1. Scale (serial)
# 2. Trickler (gpio/PWM)
# 3. Dump (gpio/servo?)
# 4. API
# 6. Bluetooth?
# 7: Powder pan/cup?

# TODO
# - document specific python version
# - handle case where scale is booted with pan on -- shows error instead of negative value
# - detect scale that's turned off (blank values)
# - validate inputs (target weight)


def trickler_loop(memcache, pid, trickler_motor, scale, target_weight, target_unit, pidtune_logger):
    pidtune_logger.info('timestamp, input (motor %), output (weight %)')
    logging.info('Starting trickling process...')

    while 1:
        # Stop running if auto mode is disabled.
        if not memcache.get('auto_mode'):
            logging.debug('auto mode disabled.')
            break

        # Read scale values (weight/unit/stable)
        scale.update()

        # Stop running if scale's unit no longer matches target unit.
        if scale.unit != target_unit:
            logging.debug('Target unit does not match scale unit.')
            break

        # Stop running if pan removed.
        if scale.weight < 0:
            logging.debug('Pan removed.')
            break

        remainder_weight = target_weight - scale.weight
        logging.debug('remainder_weight: %r', remainder_weight)

        pidtune_logger.info(
            '%s, %s, %s',
            datetime.datetime.now().timestamp(),
            trickler_motor.speed,
            scale.weight / target_weight)

        # Trickling complete.
        if remainder_weight <= 0:
            logging.debug('Trickling complete, motor turned off and PID reset.')
            break


        pid.update(float(scale.weight))
        trickler_motor.update(pid.output)
        logging.debug('trickler_motor.speed: %r, pid.output: %r', trickler_motor.speed, pid.output)
        logging.info(
            'remainder: %s %s scale: %s %s motor: %s',
            remainder_weight,
            target_unit,
            scale.weight,
            scale.unit,
            trickler_motor.speed)

    # Clean up tasks.
    trickler_motor.off()
    # Clear PID values.
    pid.clear()
    logging.info('Trickling process stopped.')


def main(config, args, pidtune_logger):
    memcache = helpers.get_mc_client()

    pid = PID.PID(
        float(config['PID']['Kp']),
        float(config['PID']['Ki']),
        float(config['PID']['Kd']))
    logging.debug('pid: %r', pid)

    trickler_motor = motors.TricklerMotor(
        memcache=memcache,
        motor_pin=int(config['motors']['trickler_pin']),
        min_pwm=int(config['motors']['trickler_min_pwm']),
        max_pwm=int(config['motors']['trickler_max_pwm']))
    logging.debug('trickler_motor: %r', trickler_motor)
    #servo_motor = gpiozero.AngularServo(int(config['motors']['servo_pin']))

    scale = scales.SCALES[config['scale']['model']](
        memcache=memcache,
        port=config['scale']['port'],
        baudrate=int(config['scale']['baudrate']),
        timeout=float(config['scale']['timeout']))
    logging.debug('scale: %r', scale)

    memcache.set('auto_mode', args.auto_mode)
    memcache.set('target_weight', args.target_weight)
    memcache.set('target_unit', scales.UNIT_MAP[args.target_unit])

    while 1:
        # Update settings.
        auto_mode = memcache.get('auto_mode', args.auto_mode)
        target_weight = memcache.get('target_weight', args.target_weight)
        target_unit = memcache.get('target_unit', args.target_unit)
        pid.SetPoint = float(target_weight)
        scale.update()

        # Set scale to match target unit.
        if target_unit != scale.unit:
            scale.change_unit()

        logging.info(
            'target: %s %s scale: %s %s auto_mode: %s',
            target_weight,
            target_unit,
            scale.weight,
            scale.unit,
            auto_mode)

        # Powder pan in place, scale stable, ready to trickle.
        if (scale.weight >= 0 and scale.weight < target_weight and scale.unit == target_unit
                and scale.is_stable and auto_mode):
            # Wait a second to start trickling.
            time.sleep(1)
            # Run trickler loop.
            trickler_loop(memcache, pid, trickler_motor, scale, target_weight, target_unit, pidtune_logger)


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    parser.add_argument('config_file')
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--auto_mode', action='store_true')
    parser.add_argument('--pid_tune', action='store_true')
    parser.add_argument('--target_weight', type=decimal.Decimal, default=0)
    parser.add_argument('--target_unit', choices=scales.UNIT_MAP.keys(), default='GN')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(args.config_file)

    helpers.setup_logging()

    if not args.verbose:
        logging.basicConfig(level=logging.INFO)

    pidtune_logger = logging.getLogger('pid_tune')
    pid_handler = logging.StreamHandler()
    pid_handler.setFormatter(logging.Formatter('%(message)s'))

    pidtune_logger.setLevel(logging.ERROR)
    if args.pid_tune:
        pidtune_logger.setLevel(logging.INFO)

    main(config, args, pidtune_logger)

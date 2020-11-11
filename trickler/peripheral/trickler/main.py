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
# - add support for config input (configparse)
# - document specific python version
# - handle case where scale is booted with pan on -- shows error instead of negative value
# - detect scale that's turned off (blank values)
# - validate inputs (target weight)


def is_even(dec):
    """Returns True if a decimal.Decimal is even, False if odd."""
    exp = dec.as_tuple().exponent
    factor = 10 ** (exp * -1)
    return (dec * factor) % 2 == 0


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


def main(args, memcache, pidtune_logger):
    pid = PID.PID(args.pid_P, args.pid_I, args.pid_D)
    logging.debug('pid: %r', pid)

    trickler_motor = motors.TricklerMotor(
        memcache=memcache,
        motor_pin=args.trickler_motor_pin,
        min_pwm=args.min_pwm,
        max_pwm=args.max_pwm)
    logging.debug('trickler_motor: %r', trickler_motor)
    #servo_motor = gpiozero.AngularServo(args.servo_motor_pin)

    scale = scales.SCALES[args.scale](
        memcache=memcache,
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout)
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
    import distutils.util

    import pymemcache.client.base
    import pymemcache.serde

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    parser.add_argument('--scale', choices=scales.SCALES.keys(), default='and-fx120')
    parser.add_argument('--scale_port', default='/dev/ttyUSB0')
    parser.add_argument('--scale_baudrate', type=int, default=19200)
    parser.add_argument('--scale_timeout', type=float, default=0.1)
    parser.add_argument('--trickler_motor_pin', type=int, default=18)
    #parser.add_argument('--servo_motor_pin', type=int)
    parser.add_argument('--max_pwm', type=float, default=100)
    parser.add_argument('--min_pwm', type=float, default=32)
    # Higher Kp values will:
    # - decrease rise time
    # - increase overshoot
    # - slightly increase settling time
    # - decrease steady-state error
    # - degrade stability
    parser.add_argument('--pid_P', type=float, default=10)
    # Higher Ki values will:
    # - slightly decrease rise time
    # - increase overshoot
    # - increase settling time
    # - largely decrease steady-state error
    # - degrade stability
    parser.add_argument('--pid_I', type=float, default=2.3)
    # Higher Kd values will:
    # - slightly decrease rise time
    # - decrease overshoot
    # - decrease settling time
    # - minorly affect steady-state error
    # - improve stability
    parser.add_argument('--pid_D', type=float, default=3.75)
    parser.add_argument('--auto_mode', type=distutils.util.strtobool, default=False)
    parser.add_argument('--target_weight', type=decimal.Decimal, default=0)
    parser.add_argument('--target_unit', choices=scales.UNIT_MAP.keys(), default='GN')
    parser.add_argument('--pid_tune', type=distutils.util.strtobool, default=False)
    parser.add_argument('--verbose', type=distutils.util.strtobool, default=False)
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    pidtune_logger = logging.getLogger('pid_tune')
    pid_handler = logging.StreamHandler()
    pid_handler.setFormatter(logging.Formatter('%(message)s'))

    pidtune_logger.setLevel(logging.ERROR)
    if args.pid_tune:
        pidtune_logger.setLevel(logging.INFO)

    memcache_client = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())
    main(args, memcache_client, pidtune_logger)

#!/usr/bin/env python3

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

# Conditions:
# 0: unknown/not ready

# TODO
# - TESTING correctly disable trickling when pan is removed
# - TESTING use stable/unstable value from scale for trickling
# - TESTING fix scale unit switching. gets stuck in a loop
# - TESTING add delay before trickling when empty pan is placed
# - add comments to code for clarity
# - add support for config input (configparse)
# - document specific python version


def trickler_loop(memcache, pid, trickler_motor, scale, args):
    running = True
    memcache.set('running', running)
    done = False

    while running:
        # Read scale values (weight/unit/stable)
        scale.update()
        # Read settings (on/off/target/etc)
        auto_mode = memcache.get('auto_mode', args.auto_mode)
        target_weight = memcache.get('target_weight', args.target_weight)
        target_unit = memcache.get('target_unit', args.target_unit)
        pid.SetPoint = float(target_weight)
        logging.debug('auto_mode: %r, target_weight: %r, target_unit: %r', auto_mode, target_weight, target_unit)

        # Set scale to match target unit.
        #if target_unit != scale.unit:
        #    scale.change_unit(target_unit)

        remainder_weight = target_weight - scale.weight
        logging.debug('remainder_weight: %r', remainder_weight)

        if args.pid_tune:
            print(f'{datetime.datetime.now().timestamp()}, {trickler_motor.speed}, {scale.weight / target_weight}')

        # Powder pan in place.
        if scale.weight >= 0 and scale.status == scales.ScaleStatus.STABLE and auto_mode and not done:
            # Wait a second to start trickling.
            time.sleep(1)
            done = False

        if scale.weight >= 0 and auto_mode and not done:
            pid.update(float(scale.weight))
            trickler_motor.update(pid.output)
            logging.debug('trickler_motor.speed: %r, pid.output: %r', trickler_motor.speed, pid.output)
        else:
            # Pan removed.
            # Turn off trickler motor.
            trickler_motor.off()
            logging.debug('Pan removed, motor turned off.')
            done = True

        # Trickling complete.
        if remainder_weight <= 0:
            # Turn off trickler motor.
            trickler_motor.off()
            # Clear PID values.
            pid.clear()
            logging.debug('Trickling complete, motor turned off and PID reset.')

        running = memcache.get('running', running)


def main(args, memcache):
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

    trickler_loop(memcache, pid, trickler_motor, scale, args)


if __name__ == '__main__':
    import argparse

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
    parser.add_argument('--auto_mode', type=bool, default=False)
    parser.add_argument('--target_weight', type=decimal.Decimal, default=0)
    parser.add_argument('--target_unit', choices=scales.UNIT_MAP.keys(), default='GN')
    parser.add_argument('--pid_tune', type=bool, default=False)
    args = parser.parse_args()

    if args.pid_tune:
        logging.basicConfig(level=logging.INFO)
        print('timestamp, input (motor %), output (weight %)')
    else:
        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
            datefmt='%Y-%m-%dT%H:%M:%S')

    memcache = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())
    main(args, memcache)

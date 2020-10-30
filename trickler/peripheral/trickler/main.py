#!/usr/bin/env python3

import decimal
import logging

import gpiozero
import pymemcache.client.base
import pymemcache.serde

import PID
import motors
import scales


memcache = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())


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


def trickler_loop(pid, trickler_motor, scale, args):
    running = True
    memcache.set('running', running)

    while running:
        # Read scale values (weight/unit/stable)
        scale.update()
        # Read settings (on/off/target/etc)
        auto_mode = memcache.get('auto_mode', args.auto_mode)
        target_weight = decimal.Decimal(memcache.get('target_weight', args.target_weight).decode('utf-8'))
        target_unit = memcache.get('target_unit', args.target_unit)
        pid.SetPoint = float(target_weight)
        logging.debug('auto_mode: %r, target_weight: %r, target_unit: %r', auto_mode, target_weight, target_unit)

        # Set scale to match target unit.
        if target_unit != scale.unit:
            scale.change_unit(target_unit)

        memcache.set('scale_weight', scale.weight)
        memcache.set('scale_unit', scale.unit)
        memcache.set('scale_status', scale.status)
        memcache.set('trickler_motor_speed', trickler_motor.speed)
        remainder_weight = target_weight - scale.weight
        logging.debug('remainder_weight: %r', remainder_weight)

        # Powder pan in place.
        if scale.weight >= 0 and auto_mode:
            pid.update(float(scale.weight))
            trickler_motor.update(pid.output)
            logging.debug('trickler_motor.speed: %r, pid.output: %r', trickler_motor.speed, pid.output)
        else:
            # Pan removed.
            # Turn off trickler motor.
            trickler_motor.off()
            logging.debug('Pan removed, motor turned off.')

        # Trickling complete.
        if remainder_weight <= 0:
            # Turn off trickler motor.
            trickler_motor.off()
            # Clear PID values.
            pid.clear()
            logging.debug('Trickling complete, motor turned off and PID reset.')

        running = memcache.get('running', running)


def main(args):
    pid = PID.PID(args.pid_P, args.pid_I, args.pid_D)
    trickler_motor = motors.TricklerMotor(args.trickler_motor_pin, min_pwm=args.min_pwm, max_pwm=args.max_pwm)
    #servo_motor = gpiozero.AngularServo(args.servo_motor_pin)

    scale = scales.SCALES[args.scale](
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout)

    trickler_loop(pid, trickler_motor, scale, args)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    parser.add_argument('--scale', choices=scales.SCALES.keys(), default='and-fx120')
    parser.add_argument('--scale_port', default='/dev/ttyUSB0')
    parser.add_argument('--scale_baudrate', type=int, default=19200)
    parser.add_argument('--scale_timeout', type=float, default=0.05)
    parser.add_argument('--trickler_motor_pin', type=int, default=18)
    #parser.add_argument('--servo_motor_pin', type=int)
    parser.add_argument('--max_pwm', type=float, default=100)
    parser.add_argument('--min_pwm', type=float, default=15)
    parser.add_argument('--pid_P', type=float, default=10)
    parser.add_argument('--pid_I', type=float, default=1)
    parser.add_argument('--pid_D', type=float, default=1)
    parser.add_argument('--auto_mode', type=bool, default=False)
    parser.add_argument('--target_weight', type=decimal.Decimal, default=0)
    parser.add_argument('--target_unit', type=int, default=scales.Units.GRAINS)
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    main(args)

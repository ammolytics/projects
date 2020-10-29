#!/usr/bin/env python3

import logging
import serial

import gpiozero
import pymemcache.client.base

import scales
import PID


memcache = pymemcache.client.base.Client('localhost')


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


def trickler_loop(pid, pwm_motor, scale, args):
    running = True
    memcache.set('running', running)

    while running:
        # Read scale values (weight/unit/stable)
        scale.update()
        # Read settings (on/off/target/etc)
        auto_mode = memcache.get('auto_mode', False)
        target_weight = memcache.get('target_weight', 0.0)
        target_unit = memcache.get('target_unit', scale.unit)
        pid.SetPoint = target_weight

        # Set scale to match target unit.
        if target_unit != scale.unit:
            scale.change_unit(target_unit)

        memcache.set('scale_weight', scale.weight)
        memcache.set('scale_unit', scale.unit)
        memcache.set('scale_status', scale.status)
        memcache.set('pwm_motor_value', pwm_motor.value)
        remainder_weight = target_weight - scale.weight

        # Powder pan in place.
        if scale.weight >= 0 and auto_mode:
            pid.update(scale.weight)
            target_pwm = pid.output
            target_pwm = max(min(int(target_pwm), args.max_pwm), args.min_pwm)
            pwm_motor.value = target_pwm / 100
        else:
            # Pan removed.
            # Turn off trickler motor.
            pmw.value = 0

        # Trickling complete.
        if remainder_weight <= 0:
            # Turn off trickler motor.
            pmw.value = 0
            # Clear PID values.
            pid.clear()

        running = memcache.get('running', running)


def main(args):
    Proportional = 10
    Integral = 1
    Derivative = 1
    pid = PID.PID(args.pid_P, args.pid_I, args.pid_D)
    pwm_motor = gpiozero.PWMOutputDevice(args.trickler_motor_pin)
    #servo_motor = gpiozero.AngularServo(args.servo_motor_pin)

    scale = scales.SCALES[args.scale](
        port=args.scale_port,
        baudrate=args.scale_baudrate,
        timeout=args.scale_timeout)

    trickler_loop(pid, pwm_motor, scale, args)


if __name_ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    parser.add_argument('scale', choices=scales.SCALES.keys())
    parser.add_argument('scale_port')
    parser.add_argument('scale_baudrate', type=int)
    parser.add_argument('scale_timeout', type=int, default=0)
    parser.add_argument('trickler_motor_pin', type=int)
    parser.add_argument('servo_motor_pin', type=int)
    parser.add_argument('max_pwm', type=float)
    parser.add_argument('min_pwm', type=float)
    parser.add_argument('pid_P', type=float)
    parser.add_argument('pid_I', type=float)
    parser.add_argument('pid_D', type=float)
    args = parser.parse_args()

    main(args)

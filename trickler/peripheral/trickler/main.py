import serial

import gpiozero
import pymemcache.client.base

import scales
import PID


memcache = pymemcache.client.base.Client('localhost')


def trickler_loop(pid, pwm, scale, args):
    running = True
    memcache.set('running', running)

    while running:
        # Read scale values (weight/unit/stable)
        # Read settings (on/off/target/etc)

        scale.update()

        pid.update(scale.weight)
        target_pwm = pid.output
        target_pwm = max(min(int(target_pwm), args.max_pwm), args.min_pwm)

        pwm.value = target_pwm / 100

        target_weight = memcache.get('target_weight')

        total_divs = target_weight / unit_res
        remainder_weight = target_weight - scale.weight
        remainder_divs = remainder_weight / unit_res
        remainder_perc = (remainder_divs / total_divs) * 100

        running = memcache.get('running', running)


def main(args):
    Proportional = 10
    Integral = 1
    Derivative = 1
    pid = PID.PID(Proportional, Integral, Derivative)
    pwm = gpiozero.PWMOutputDevice(args.motor_pin)

    scale = scales.SCALES[args.scale](port=args.scale_port, baudrate=args.scale_baudrate, timeout=args.scale_timeout)

    trickler_loop(pid, pwm, scale, args)


if __name_ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    args = parser.parse_args()
    # TODO(eric): args.scale
    # TODO(eric): args.scale_port
    # TODO(eric): args.scale_baudrate
    # TODO(eric): args.scale_timeout
    # TODO(eric): args.motor_pin
    # TODO(eric): args.max_pwm
    # TODO(eric): args.min_pwm

    main(args)

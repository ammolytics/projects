#!/usr/bin/env python3

import logging

import gpiozero


class TricklerMotor(object):

    def __init__(self, motor_pin=18, min_pwm=15, max_pwm=100):
        self.pwm = gpiozero.PWMOutputDevice(motor_pin)
        self.min_pwm = min_pwm
        self.max_pwm = max_pwm
        logging.debug('Created pwm motor on PIN %r with min %r and max %r: %r', motor_pin, self.min_pwm, self.max_pwm, self.pwm)

    def update(self, target_pwm):
        logging.debug('Updating target_pwm to %r', target_pwm)
        target_pwm = max(min(int(target_pwm), self.max_pwm), self.min_pwm)
        logging.debug('Adjusted clamped target_pwm to %r', target_pwm)
        self.set_speed(target_pwm / 100)

    def set_speed(self, speed):
        # TODO(eric): must be 0 - 1.
        logging.debug('Setting speed from %r to %r', self.speed, speed)
        self.pwm.value = speed

    def off(self):
        self.set_speed(0)

    @property
    def speed(self):
        return self.pwm.value


if __name__ == '__main__':
    import argparse
    import time

    parser = argparse.ArgumentParser(description='Test motors.')
    parser.add_argument('--trickler_motor_pin', type=int, default=18)
    #parser.add_argument('--servo_motor_pin', type=int)
    parser.add_argument('--max_pwm', type=float, default=100)
    parser.add_argument('--min_pwm', type=float, default=15)
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    motor = TricklerMotor(args.trickler_motor_pin, min_pwm=args.min_pwm, max_pwm=args.max_pwm)
    print('Spinning up trickler motor in 3 seconds...')
    time.sleep(3)
    for x in range(1, 11):
        motor.set_speed(x / 10)
        time.sleep(2)
    motor.off()
    print('Done.')

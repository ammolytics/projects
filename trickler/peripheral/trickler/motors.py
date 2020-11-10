#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import atexit
import logging

import gpiozero


class TricklerMotor:
    """Controls a small vibration DC motor with the PWM controller on the Pi."""

    def __init__(self, memcache, motor_pin=18, min_pwm=15, max_pwm=100):
        """Constructor."""
        self._memcache = memcache
        self.pwm = gpiozero.PWMOutputDevice(motor_pin)
        self.min_pwm = min_pwm
        self.max_pwm = max_pwm
        logging.debug(
            'Created pwm motor on PIN %r with min %r and max %r: %r',
            motor_pin,
            self.min_pwm,
            self.max_pwm,
            self.pwm)
        atexit.register(self._graceful_exit)

    def _graceful_exit(self):
        """Graceful exit function, turn off motor and close GPIO pin."""
        logging.debug('Closing trickler motor...')
        self.pwm.off()
        self.pwm.close()

    def update(self, target_pwm):
        """Change PWM speed of motor (int), enforcing clamps."""
        logging.debug('Updating target_pwm to %r', target_pwm)
        target_pwm = max(min(int(target_pwm), self.max_pwm), self.min_pwm)
        logging.debug('Adjusted clamped target_pwm to %r', target_pwm)
        self.set_speed(target_pwm / 100)

    def set_speed(self, speed):
        """Sets the PWM speed (float) and circumvents any clamps."""
        # TODO(eric): must be 0 - 1.
        logging.debug('Setting speed from %r to %r', self.speed, speed)
        self.pwm.value = speed
        self._memcache.set('trickler_motor_speed', self.speed)

    def off(self):
        """Turns motor off."""
        self.set_speed(0)

    @property
    def speed(self):
        """Returns motor speed (float)."""
        return self.pwm.value


if __name__ == '__main__':
    import argparse
    import time

    import pymemcache.client.base
    import pymemcache.serde

    parser = argparse.ArgumentParser(description='Test motors.')
    parser.add_argument('--trickler_motor_pin', type=int, default=18)
    #parser.add_argument('--servo_motor_pin', type=int)
    parser.add_argument('--max_pwm', type=float, default=100)
    parser.add_argument('--min_pwm', type=float, default=15)
    args = parser.parse_args()

    memcache_client = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    motor = TricklerMotor(
        memcache=memcache_client,
        motor_pin=args.trickler_motor_pin,
        min_pwm=args.min_pwm,
        max_pwm=args.max_pwm)
    print('Spinning up trickler motor in 3 seconds...')
    time.sleep(3)
    for x in range(1, 101):
        motor.set_speed(x / 100)
        time.sleep(.05)
    for x in range(100, 0, -1):
        motor.set_speed(x / 100)
        time.sleep(.05)
    motor.off()
    print('Done.')

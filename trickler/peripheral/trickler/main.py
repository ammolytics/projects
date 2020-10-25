import serial

import gpiozero

import PID


def trickler_loop(pid, pwm, scale, args):
    running = True

    while running:
        # Read scale values (weight/unit/stable)
        # Read settings (on/off/target/etc)

        config = getConfig()
        running = config.running

        pid.update(scale.weight)
        targetPwm = pid.output
        targetPwm = max(min(int(targetPwm), args.maxPwm), args.minPwm)

        pwm.value = targetPwm / 100

        total_divs = target_weight / unit_res
        remainder_weight = target_weight - current_weight
        remainder_divs = remainder_weight / unit_res
        remainder_perc = (remainder_divs / total_divs) * 100


def getConfig():
    pass


def main(args):
    P = 10
    I = 1
    D = 1
    pid = PID.PID(P, I, D)
    pwm = gpiozero.PWMOutputDevice(args.motorPIN)

    scale = serial.Serial()
    scale.port = args.devPath
    scale.baudrate = args.baudRate
    scale.timeout = args.scaleTimeout

    trickler_loop(pid, pwm, scale, args)


if __name_ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run OpenTrickler.')
    args = parser.parse_args()

    main(args)

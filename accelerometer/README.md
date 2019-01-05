# Ammolytics Project: Inexpensive Firearm Accelerometer


## Software

The Arduino software for this project is in the [`sensor_logger.ino`](https://github.com/ammolytics/projects/blob/master/accelerometer/sensor_logger.ino) file. It's based on the [example code](https://github.com/adafruit/Adafruit_LIS3DH) from Adafruit for the [LIS3DH sensor](https://amzn.to/2PASGsD).


## Hardware

- [Adafruit LIS3DH Triple-Axis Accelerometer](https://amzn.to/2PASGsD)
- [Adafruit Feather M0 Bluefruit LE](https://amzn.to/2ryuGN1)
- [Adalogger FeatherWing - RTC + SD](https://amzn.to/2EsIelH)
- [3.7V 500maH LiPo Battery](https://amzn.to/2UASH3g)
- [3d-printable mount](https://grabcad.com/library/3-axis-acceleration-sensor-mount-1)


## Instructions

There are excellent guides available from both Adafruit and Sparkfun which explain how to wire the sensor correctly.

- [Adafruit: LIS3DH Triple-Axis Accelerometer Breakout Guide](https://learn.adafruit.com/adafruit-lis3dh-triple-axis-accelerometer-breakout?view=all)
- [Sparkfun: LIS3DH Hookup Guide](https://learn.sparkfun.com/tutorials/lis3dh-hookup-guide/all)

And another for how to setup the RTC date/time and write to the SD card.

- [Adafruit: Adalogger FeatherWing Guide](https://learn.adafruit.com/adafruit-adalogger-featherwing?view=all)

After assembling the hardware, you'll need to install the software in this repo onto the Feather board. For use at the range, I recommend disabling the `DEBUG` flag by commenting out the following line:

```
// Enable debug logger.
// Note: Comment out before running in real-world.
#define DEBUG
```

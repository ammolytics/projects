# Ammolytics Project: Inexpensive Firearm Accelerometer

This project was first featured in an article which investigated the effects [Recoil has on Muzzle Velocity](https://blog.ammolytics.com/2018-12-12/experiment-recoil-vs-muzzle-velocity.html), and was [described in more detail](https://blog.ammolytics.com/2019-01-01/project-cheap-rifle-accelerometer.html) in a later article.

## Software

The Arduino software for this project is in the [`sensor_logger.ino`](https://github.com/ammolytics/projects/blob/master/accelerometer/sensor_logger.ino) file. It's based on the [example code](https://github.com/adafruit/Adafruit_LIS3DH) from Adafruit for the [LIS3DH sensor](https://www.amazon.com/gp/product/B01BU70B64/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B01BU70B64&linkId=e9c352ddd0167d5c759dca3fdacf3b4f).


## Hardware

- [Adafruit LIS3DH Triple-Axis Accelerometer](https://www.amazon.com/gp/product/B01BU70B64/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B01BU70B64&linkId=e9c352ddd0167d5c759dca3fdacf3b4f)
- [Adafruit Feather M0 Bluefruit LE](https://www.amazon.com/gp/product/B01E1RESIM/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B01E1RESIM&linkId=9507195f4dfddf256d968238564249e7)
- [Adalogger FeatherWing - RTC + SD](https://www.amazon.com/gp/product/B01BZRN8B4/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B01BZRN8B4&linkId=5eac489f1c000cc92d82123bc90ae135)
- [3.7V 500maH LiPo Battery](https://www.amazon.com/gp/product/B0798DV4BS/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B0798DV4BS&linkId=f1c1fc4510ad081c0223ce9a010871f5)
- [3D-printed mount](https://www.thingiverse.com/thing:3343163)


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

## Data Output

When the unit is powered up, it will create a new file based on the date/time in this format:

    YYYYMMDDHHmm.csv

While it's running, it stores a few seconds of acceleration data in memory before writing to disk. The write opertation can take around `10ms`, which is too slow to do constantly. It does write often enough that you should not lose much data at all when powering down.

Acceleration values are in [`G`s](https://en.wikipedia.org/wiki/G-force#Unit_and_measurement), which can easily be converted to metric or imperial units.

Here's an example of the resulting data set. 

| timestamp (s) | start (µs) | delta (µs) | accel x (G) | accel y (G) | accel z (G) |
| -- | -- | -- | -- | -- | -- |
| 1547749706 | 123593 | 223 | 0.75 | 1.19 | -0.19 |
| 1547749706 | 125917 | 251 | 0.80 | 1.19 | -0.22 |
| 1547749706 | 126979 | 252 | 0.85 | 1.11 | -0.21 |
| 1547749706 | 128040 | 252 | 0.85 | 1.09 | -0.26 |
| 1547749706 | 129097 | 251 | 0.94 | 1.05 | -0.22 |
| 1547749706 | 130158 | 252 | 0.97 | 1.02 | -0.20 |

# Ammolytics: Open Trickler Controller

**Now in Python!**
The system was rewritten from scratch. It now supports PID controls, PWM motor control, among other things. [See PR 51 for more info!](https://github.com/ammolytics/projects/pull/51)
  
This portion of the Open Trickler is used to control the scale and trickler motor. It's designed to be run on a Raspberry Pi Zero W, but any similar system which supports Bluetooth may work, but I have not tested them.


## Support

Need help? [Check the FAQ](https://github.com/ammolytics/projects/tree/develop/trickler#frequently-asked-questions) or [join our Discord Server](https://discord.gg/WqTbyK2) to chat with other folks who are building the Open Trickler and helping each other out.

This is a free, open-source project which does not come with any official support or warranty.


## Installing Latest Firmware

1. Download the latest firmware image: [`opentrickler-python-20210814-PROD.img.xz`](https://drive.google.com/file/d/1Fe7pqHpg_yUvkC7nm8q0EPcZy5OtW1Yc/view?usp=sharing)
  `SHA256 (opentrickler-python-20210814-PROD.img.xz) = 649b047b9b2ab5906686382008afecd590170a1f62cf16247d34621b7d583025`
1. Flash your microSD card using [balenaEtcher](https://www.balena.io/etcher/)
  I **highly** recommend the free [balenaEtcher program](https://www.balena.io/etcher/) for this step as it's much smarter and less error/mistake prone.
1. Open the `BOOT` partition (shows up like a USB-drive when plugged into your computer) on the microSD card. Edit the `wpa_supplicant.conf` file with your WiFi settings.
  Optional, but recommended since it provides more debugging capabilities through your browser at [http://opentrickler.local](http://opentrickler.local).
  See here for more help: https://www.raspberrypi.org/documentation/configuration/wireless/headless.md
1. Open the `CODE` parition on the microSD card. Edit the `opentrickler_config.ini` file to modify the Open Trickler settings. Defaults should work for most people.
1. Plug the microSD card into your Pi.
1. Turn on your scale.
1. Turn on your Pi to boot the Open Trickler system.
1. The onboard LED should "pulse" once it's booted up and ready!
1. Connect with your mobile app.

Please share any feedback/results on [Discord](https://discord.gg/WqTbyK2) or in a [GitHub issue](https://github.com/ammolytics/projects/issues).


## Debugging

Once your Open Trickler has booted up, you can visit [http://opentrickler.local](http://opentrickler.local) in your browser to access its log files. This is helpful for debugging issues with the stock Open Trickler software, hardware problems, and any issues with your own custom software code changes.

**Note:** Accessing the opentrickler.local website requires putting your Open Trickler onto your wireless network, as described in Step 3 of the Instructions.


## Customizing Your Open Trickler

To make it easier for anyone to customize and tinker with the software code on their Open Trickler, a `CODE` partition has been added which will appear after you flash your SD card using one of the images listed in this document. The `CODE` partition contains the same Python code you see in this GitHub repository. If you change the code on your SD card, your Open Trickler will run it -- simple!


## For Developers

The development SD card image described below provides SSH access to the Raspberry Pi, which is useful for development and advanced debugging.
The main difference is that SSH access is enabled. Don't use this unless you are familiar with the Linux command line.
All firmware images are generated using [buildroot](https://buildroot.org/) and **do not have the same utilities available** as [Raspberry Pi OS](https://www.raspberrypi.org/software/).

1. Clone this repository.
  I highly recommend making changes on your computer then copying them to the microSD card.
1. Download the latest **development** firmware image:
  [`opentrickler-python-20210814-DEV.img.xz`]()https://drive.google.com/file/d/1q7YvOHOx1h7B_rL1UD9nudy-sgMhuCzV/view?usp=sharing
  `SHA256 (opentrickler-python-20210814-DEV.img.xz) = 1b8dbdbcfb76c9c6706ebfebfc981e6238a6107c24640619218087e01b0a277e`
1. Follow the regular instructions above to flash the image.
1. You can log into your running Open Trickler over SSH with the following info:  
  `ssh root@opentrickler.local` (p: `ammolytics`)


## Developer Setup Instructions

If you're going to write and test code on your computer, these steps will help you to set up the dependencies.

1. Install memcached  
  ```sudo apt install memcached```
1. Pull github branch
1. Create virtual environment  
  ```python3 -m venv .venv```
1. Activate virtual environment  
  ```source .venv/bin/activate```
1. Install dependencies  
  ```pip install -r requirements-to-freeze.txt```


# References

- https://github.com/Adam-Langley/pybleno
- https://onion.io/2bt-pid-control-python/
- https://github.com/ivmech/ivPID/blob/master/PID.py
- http://cgkit.sourceforge.net/doc2/pidcontroller.html
- https://github.com/yamins81/cgkit/blob/6ec3f9b32c0330057d3c2c0bfcba573dac267aac/cgkit/pidcontroller.py
- https://gpiozero.readthedocs.io/en/stable/api_output.html#gpiozero.PWMOutputDevice
- https://pythonhosted.org/pyserial/shortintro.html
- https://realpython.com/python-memcache-efficient-caching/
- https://github.com/pinterest/pymemcache
- https://pymemcache.readthedocs.io/en/latest/
- https://learn.adafruit.com/adafruit-arduino-lesson-13-dc-motors?view=all

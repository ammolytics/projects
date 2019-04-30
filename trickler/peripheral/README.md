# Ammolytics: Open Trickler Controller

This portion of the Open Trickler is used to control the scale and trickler motor. It's designed to be run on a Raspberry Pi Zero W, but any similar system which supports Bluetooth will likely work as well.

# Instructions

[Download](https://www.raspberrypi.org/downloads/raspbian/) and [install](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) Raspbian Lite.
I recommend [enabling SSH and Wifi](https://desertbot.io/blog/setup-pi-zero-w-headless-wifi)

Once booted, connect via SSH
```
ssh pi@raspberrypi@local
```

Initial configuration
```
sudo raspi-config
```

From the menu:
- Change `Network > Hostname` from `raspberrypi` to `opentrickler` 
- Run `Advanced Options > Expand Filesystem` to provide more space on the SD card

After making this changes, select `Finish`. It will ask if you want to reboot, select `Yes`.
At this point, you will be disconnected. It'll take about 60 seconds for the system to come back online with a new hostname.

Reconnect with SSH
```
ssh pi@opentrickler.local
```

Install system dependencies

```
sudo apt-get update
sudo apt-get install -yqq git bluetooth bluez libbluetooth-dev libudev-dev
```

Get a copy of the Open Trickler code
```
git clone https://github.com/ammolytics/projects.git
```

Run the Open Trickler setup script

_**Note:** The `setup.sh` script is intended for the Pi Zero W. If you're using a different board, you'll need to change the version of NodeJS from `armv6l` to match the chipset of your system._
```
cd projects/trickler/peripheral
./bin/setup.sh
```

Start the Open Trickler
```
node index.js /dev/ttyUSB0
```

To run it as a service
```
pm2 start ecosystem.config.js
pm2 startup systemd
```
Run the command that it returns, which will look something like `sudo env PATH=$PATH:/usr/local/.../node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
`
```
pm2 save
sudo systemctl start pm2-pi
```

## For Developers

Note: Most of the development was done on a Mac, and the setup scripts reflect that.

First, clone this repository

Next, run the setup script. This will create a virtual environment with the same version of NodeJS that's used on the Pi, and install other dependencies.
```
./bin/setup.sh
```

That's it! If you don't have an A&D scale, I created a very simple mock to fill in some of those gaps. You can a server that uses it with the following command.
```
./bin/mock.sh
```


## References
- [Headless Raspberry Pi Zero W Setup](https://dev.to/vorillaz/headless-raspberry-pi-zero-w-setup-3llj)
- [Headless Raspberry Pi Zero W setup with SSH and Wi-Fi](https://medium.com/@jay_proulx/headless-raspberry-pi-zero-w-setup-with-ssh-and-wi-fi-8ddd8c4d2742)
- [Raspberry Pi Zero Headless Quick Start](https://learn.adafruit.com/raspberry-pi-zero-creation?view=all)
- [Headless Pi Zero W WiFi Setup (Mac)](https://desertbot.io/blog/setup-pi-zero-w-headless-wifi)
- [bleno Instructions](https://github.com/noble/bleno)
- [Arduino Lesson 13: DC Motors](https://learn.adafruit.com/adafruit-arduino-lesson-13-dc-motors?view=all)
- [How To Set Up a Node.js Application for Production on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-18-04)

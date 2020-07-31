# Ammolytics: Open Trickler Controller
  
This portion of the Open Trickler is used to control the scale and trickler motor. It's designed to be run on a Raspberry Pi Zero W, but any similar system which supports Bluetooth may work, but I have not tested them.

# Instructions

1. Download the latest SD card image:  
  [`opentrickler-20200528-PROD.img.xz`](https://drive.google.com/open?id=18Q4nF9Ur_vaZgMkSsSwSa-qUwd2g9Qhx)  
  sha256: `469273bf4de0b583aaac2f4a3f7f4382b1884c97cd167113582f8ff267ab235e`
2. Flash the image to your microSD card.  
  I **highly** recommend the free [balenaEtcher program](https://www.balena.io/etcher/) for this step as it's much smarter and less error/mistake prone.
3. Add your WiFi network details to the `wpa_supplicant.conf` file on the `BOOT` partition.  
  Optional, but recommended since it provides more debugging capabilities through your browser at [http://opentrickler.local](http://opentrickler.local).
4. Insert the microSD card into your Raspberry Pi Zero W.
5. Turn on your scale.
6. Boot up your Open Trickler!

## Debugging

Once your Open Trickler has booted up, you can visit [http://opentrickler.local](http://opentrickler.local) in your browser to access its log files. This is helpful for debugging issues with the stock Open Trickler software, hardware problems, and any issues with your own custom software code changes.

**Note:** Accessing the opentrickler.local website requires putting your Open Trickler onto your wireless network, as described in Step 3 of the Instructions.

## Customizing Your Open Trickler

To make it easier for anyone to customize and tinker with the software code on their Open Trickler, a `CODE` partition has been added which will appear after you flash your SD card using one of the images listed in this document. The `CODE` partition contains the same JavaScript code you see in this GitHub repository. If you change the code on your SD card, your Open Trickler will run it -- simple!

## For Developers

The development SD card image described below provides SSH access to the Raspberry Pi, which is useful for development and advanced debugging.

1. Clone this repository.
2. Download the latest **development** SD card image:  
  [`opentrickler-20200528-DEV.img.xz`](https://drive.google.com/open?id=16DJdv4G5Ovct19GoDcUUK3jPjrD0Cf5D)  
  sha256: `1448eaea651111f944ac7dc19ebe01aa37128de7f448af99fa60cb8d4cf23ab7`
3. Follow the regular instructions above.
4. You can SSH to your running Open Trickler with the following command:  
  `ssh root@opentrickler.local` (p: `ammolytics`)


### Notes

- Most of the development was done on Apple and Linux machines, so the code and environment reflects that.
- I use [`nodenv`](https://github.com/nodenv/nodenv) to maintain several different versions of NodeJS on my machine and I recommmend it for this project.
-  If you don't have an A&D scale, I created a very simple mock to fill in some of those gaps. You can a server that uses it with the following command:
  `./bin/mock.sh`


## References
- [Arduino Lesson 13: DC Motors](https://learn.adafruit.com/adafruit-arduino-lesson-13-dc-motors?view=all)

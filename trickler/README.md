# Ammolytics Project: Open Trickler

The Open Trickler is described in greater detail [in this article](https://blog.ammolytics.com/2019-04-30/diy-smart-trickler.html).

## Support

Need help? [Join our Discord Server](https://discord.gg/WqTbyK2) to chat with other folks who are building the Open Trickler and helping each other out.

This is a free, open-source project which does not come with any official support or warranty.


## Software

The Mobile app for this project uses the [Flutter framework](https://flutter.dev/). The code can be found in the [`mobile/`](https://github.com/ammolytics/projects/blob/develop/trickler/mobile/) directory.

The Controller is a [NodeJS (`v12.x`)](https://nodejs.org/docs/latest-v12.x/api/) application which reads from the scale's serial port and controls the trickler. It was designed to be run on a Raspberry Pi Zero W. The code can be found in the [`peripheral/`](https://github.com/ammolytics/projects/blob/develop/trickler/peripheral/) directory.

## Hardware

_Affiliate links may be used above to help support Ammolytics._

- One [Raspberry Pi Zero W kit](https://www.amazon.com/gp/product/B0748MPQT4/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B0748MPQT4&linkId=382e0c8e4f0c17aa292c6a001346b5aa)
- One [Adafruit mini proto board](https://www.amazon.com/gp/product/B07115Z42P/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B07115Z42P&linkId=9fee45aeba77c33472321e1de5bf1810) or similar
- One [16GB MicroSD card](https://www.amazon.com/gp/product/B079H6PDCK/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B079H6PDCK&linkId=892c31a29914fd2abb249ccdaa0acf72)
- One [Serial to USB cable](https://www.amazon.com/gp/product/B0769FY7R7/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B0769FY7R7&linkId=35f392bd7bfdae3ec7dfa542c8da93ae)  
  **Update:** I previously linked to a [different model](https://www.amazon.com/gp/product/B07GNKMHFW/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B07GNKMHFW&linkId=7e56918820cec6487da2e539bb71b658) of Serial to USB cable, but many people were having issues with it. Thanks to @cyclepath37 for finding a more reliable cable!
- One [Null modem adapter](https://www.amazon.com/gp/product/B075XHWVSJ/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B075XHWVSJ&linkId=7c662ec9d4021bf3c1374f86ff1b9b0d) (2-pack)  
  **Note:** Don't skip this part! It changes some wiring that's needed in order for things to work correctly.
- One [3v Mini vibration motors](https://www.amazon.com/gp/product/B073JKQ9LN/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B073JKQ9LN&linkId=10aa986c321d3db502b48a232c0b5430) (15-pack)
- One NPN 2222 transistor or similar
- One 1N4001 diode or similar
- One 200 Ω resistor or similar
- [Jumper wires](https://www.amazon.com/gp/product/B00J5NSOVA/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B00J5NSOVA&linkId=0a063bdee530b9d656b501b15204d212)
- [3/8" brass tube](https://www.amazon.com/gp/product/B004QAXRFU/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B004QAXRFU&linkId=6fd7786f2f4a3c6649d3b899e688331a) (enough for several)
- [5/16" aluminum tube](https://www.amazon.com/gp/product/B00G6J78WW/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B00G6J78WW&linkId=b20993d8facc9d75e48e0f8e36963dff) (enough for 6)
- [1/4-20 x 3/4" socket head screw](https://www.amazon.com/gp/product/B01A9ELIM0/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B01A9ELIM0&linkId=e0b58b6b19e9e7281b8ee26fc0662999)
- [O-rings](https://www.amazon.com/gp/product/B07G9ZK2JV/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B07G9ZK2JV&linkId=f8239414c4900ecf100b91d346f21333)


## Instructions

Please see the following:

- [Mobile app instructions](https://github.com/ammolytics/projects/blob/develop/trickler/mobile/README.md)
- [Controller instructions](https://github.com/ammolytics/projects/blob/develop/trickler/peripheral/README.md)


## Frequently Asked Questions

- [Why isn't Bluetooth working?](#why-isnt-bluetooth-working)
- [Why can't I see the `CODE` partition from my computer?](#why-cant-i-see-the-code-partition-from-my-computer)
- [Why can't I access the debug webpage?](#why-cant-i-access-the-debug-webpage)
- [Can you add support for my scale?](#can-you-add-support-for-my-scale)
- [Can you make it work with an Arduino or ESP?](#can-you-make-it-work-with-an-arduino-or-esp)
- [Can you add support for a powder drop?](#can-you-add-support-for-a-powder-drop)


### Why isn't Bluetooth working?

The Open Trickler software [won't advertise on Bluetooth until it detects the scale](https://github.com/ammolytics/projects/blob/develop/trickler/peripheral/lib/index.js#L63-L72). This can confuse people the most who try to boot up and test a device that's not connected to a scale.

Assuming you do have a supported scale connected, here are a few other debug tips:

- Don't try to pair from your system settings. Instead, you should connect to the Open Trickler device from the Bluetooth menu within the app.  
  Modern Bluetooth devices (aka Bluetooth LE) don't require pairing like you might be used to.
- Ensure that the scale has been properly configured.  
  Without following these steps, your scale will not send any data over the serial cable to the Open Trickler/Raspberry Pi unit.
- Are you using the [null modem adapter](https://www.amazon.com/gp/product/B075XHWVSJ/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B075XHWVSJ&linkId=7c662ec9d4021bf3c1374f86ff1b9b0d)?  
  Even though you can _physically_ connect the USB-to-Serial adapter directly to your scale, it **will not function properly** without the null modem adapter.
- Check the make/model of USB-to-Serial adapter. The first adapter I used (and linked to) ended up being unreliable for many folks, so I now [recommend a different adapter](https://www.amazon.com/gp/product/B0769FY7R7/ref=as_li_qf_asin_il_tl?ie=UTF8&tag=ammolytics0f-20&creative=9325&linkCode=as2&creativeASIN=B0769FY7R7&linkId=35f392bd7bfdae3ec7dfa542c8da93ae) (which also happens to be less expensive)


### Why can't I see the `CODE` partition from my computer?

The `CODE` partition is formatted with the FAT32 filesystem and is intended to make it easier for folks to tinker with the code on the Open Trickler without requiring advanced technical skills. Unfortunately, if you're using the Windows operating system older than version 10, it may not work for you.

Even on Windows 10, the `CODE` parition may not automatically appear as a drive you can access. You might need to assign it a drive letter from the Disk Manager. Thanks to [ande7824 for this tip](https://github.com/ammolytics/projects/issues/42#issuecomment-673627027)!


### Why can't I access the debug webpage?

Use of the debug webpage depends on connecting the Open Trickler to your WiFi network.

Make sure that the device you're using to access the debug webpage is:
- connected to the same WiFi network
- not connected to or running VPN software
- lists `192.168.1.1` as one of the DNS servers in the network settings

Accessing the Open Trickler debug webpage at http://opentrickler.local requires support for [mDNS](https://en.wikipedia.org/wiki/Multicast_DNS). If you're running Windows, you may need to [install some additional software](https://support.apple.com/kb/dl999?locale=en_US).


### Can you add support for my scale?

It's challenging to add support for a scale that I don't own or have physical access to. The open source nature of this project lends itself towards others adding support for additional scales. If you're willing to do some of the work, then I'm willing to help add support for your scale.

Some scales are easier to support than others. I've had a few folks ask about supporting analog balance beam scales. Anything is possible with enough work, but those are likely outside the scope of the Open Trickler's design.


### Can you make it work with an Arduino or ESP?

This would require a full rewrite and rethinking of the entire project. Since it works well enough as is and has potential for even more advanced capabilities, I'm not inclined to use an alternate board.

That said, you're welcome to reference and adapt the Open Trickler software if you're interested in doing that work. That's the beauty of open source software!


### Can you add support for a powder drop?

Personally, I don't care for the powder drop design of the AutoTrickler and I'm not inclined to utilize it myself. That said, I can understand why some folks want this and that's great!

[See this ticket](https://github.com/ammolytics/projects/issues/21) if you're interested in working on this and adding it to the Open Trickler.

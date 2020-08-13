# Ammolytics Project: Open Trickler

The Open Trickler is described in greater detail [in this article](https://blog.ammolytics.com/2019-04-30/diy-smart-trickler.html).

## Support

Need help? [Join our Discord Server](https://discord.gg/WqTbyK2) to chat with other folks who are building the Open Trickler and helping each other out.

This is a free, open-source project which does not come with any official support or warranty.


## Software

The Mobile app for this project uses the [Flutter framework](https://flutter.dev/). The code can be found in the [`mobile/`](https://github.com/ammolytics/projects/blob/develop/trickler/mobile/) directory.

The Controller is a [NodeJS (`v12.x`)](https://nodejs.org/docs/latest-v12.x/api/) application which reads from the scale's serial port and controls the trickler. It was designed to be run on a Raspberry Pi Zero W. The code can be found in the [`peripheral/`](https://github.com/ammolytics/projects/blob/develop/trickler/peripheral/) directory.

## Hardware

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


_Affiliate links may be used above to help support Ammolytics._

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')


class WeightCharacteristic extends bleno.Characteristic {
  constructor(trickler) {
    super({
      uuid: '10000001-be5f-4b43-a49f-76f2d65c6e28',
      properties: ['read', 'notify'],
      descriptors: [
        new bleno.Descriptor({
          uuid: '2901',
          value: 'Reads the current weight value of the scale'
        })
      ]
    })

    this.trickler = trickler
    this.listener = this.sendWeightNotification.bind(this)
  }


  onReadRequest (offset, callback) {
    console.log(`weight read request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG, null)
    } else {
      var data = Buffer.from(Number(this.trickler.weight).toString())
      callback(this.RESULT_SUCCESS, data)
    }
  }


  sendWeightNotification (result) {
    if (process.env.DEBUG) {
      console.log(`Trying to send weight: ${result}`)
    }
    if (this.updateValueCallback) {
      var data = Buffer.from(Number(result).toString())
      if (process.env.DEBUG) {
        console.log(`Sending weight notification: ${data}`)
      }
      this.updateValueCallback(data)
    }
  }


  onSubscribe (maxValueSize, updateValueCallback) {
    this.maxValueSize = maxValueSize
    this.updateValueCallback = updateValueCallback
    console.log(`Subscribed to weight characteristic.`)

    this.trickler.on('weight', this.listener)
  }


  onUnsubscribe () {
    this.maxValueSize = null
    this.updateValueCallback = null
    console.log('Unsubscribed from weight characteristic')

    this.trickler.removeListener('weight', this.listener)
  }
}


module.exports = WeightCharacteristic

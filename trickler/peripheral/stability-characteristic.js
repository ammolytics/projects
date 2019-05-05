/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')


class StabilityCharacteristic extends bleno.Characteristic {

  constructor(trickler) {
    super({
      uuid: '10000002-be5f-4b43-a49f-76f2d65c6e28',
      properties: ['read', 'notify'],
      descriptors: [
        new bleno.Descriptor({
          uuid: '2901',
          value: 'Reads the current stability status of the scale'
        })
      ]
    })

    this.trickler = trickler
    this.listener = this.sendStatusNotification.bind(this)
  }


  onReadRequest (offset, callback) {
    console.log(`stability read request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG, null)
    } else {
      var data = Buffer.alloc(1)
      data.writeUInt8(this.trickler.status, 0)
      callback(this.RESULT_SUCCESS, data)
    }
  }


  sendStatusNotification (result) {
    if (this.updateValueCallback) {
      var data = Buffer.alloc(1)
      data.writeUInt8(result, 0)
      this.updateValueCallback(data)
    }
  }


  onSubscribe (maxValueSize, updateValueCallback) {
    console.log(`Subscribed to stability.`)
    this.maxValueSize = maxValueSize
    this.updateValueCallback = updateValueCallback

    this.trickler.on('status', this.listener)
  }


  onUnsubscribe () {
    console.log(`Unsubscribed from stability.`)
    this.maxValueSize = null
    this.updateValueCallback = null

    this.trickler.removeListener('status', this.listener)
  }
}


module.exports = StabilityCharacteristic

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')


class AutoModeCharacteristic extends bleno.Characteristic {

  constructor (trickler) {
    super({
      uuid: '10000005-be5f-4b43-a49f-76f2d65c6e28',
      properties: ['read', 'write'],
      descriptors: [
        new bleno.Descriptor({
          uuid: '2901',
          value: 'Start/stop automatic trickle mode'
        })
      ]
    })

    this.trickler = trickler
    this.listener = this.sendAutoModeNotification.bind(this)
  }

  sendAutoModeNotification (result) {
    console.log(`this.updateValueCallback: ${this.updateValueCallback}`)
    if (this.updateValueCallback) {
      var data = Buffer.alloc(1)
      data.writeUInt8(result, 0)
      console.log(`Calling this.updateValueCallback with ${data}`)
      this.updateValueCallback(data)
    }
  }

  onReadRequest (offset, callback) {
    console.log(`autoMode read request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG, null)
    } else {
      var data = Buffer.alloc(1)
      data.writeUInt8(this.trickler.autoMode, 0);
      callback(this.RESULT_SUCCESS, data)
    }
  }


  onSubscribe (maxValueSize, updateValueCallback) {
    console.log(`Subscribe from autoMode`)
    this.maxValueSize = maxValueSize
    this.updateValueCallback = updateValueCallback

    this.trickler.on('autoMode', this.listener)
  }


  onUnsubscribe () {
    console.log(`Unsubscribe from autoMode`)
    this.maxValueSize = null
    this.updateValueCallback = null

    this.trickler.removeListener('autoMode', this.listener)
  }


  onWriteRequest (data, offset, withoutResponse, callback) {
    console.log(`autoMode write request`)
    if (offset) {
      console.log(`Invalid offset: ${offset}`)
      callback(this.RESULT_ATTR_NOT_LONG)
    } else if (data.length !== 1) {
      console.log(`Invalid data.length: ${data.length}`)
      callback(this.RESULT_INVALID_ATTRIBUTE_LENGTH)
    } else {
      var autoMode = data.readUInt8(0)
      console.log(`request to switch autoMode from ${this.trickler.autoMode} to ${autoMode}`)
      this.trickler.once('autoMode', result => {
        console.log(`autoMode result: ${result}`)
        callback(this.RESULT_SUCCESS)
      })
      this.trickler.autoMode = autoMode
    }
  }

}


module.exports = AutoModeCharacteristic

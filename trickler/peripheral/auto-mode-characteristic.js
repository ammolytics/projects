/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')
const trickler = require('./trickler')


function AutoModeCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
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
}


util.inherits(AutoModeCharacteristic, bleno.Characteristic)


AutoModeCharacteristic.prototype.sendAutoModeNotification = function(result) {
  console.log(`this.updateValueCallback: ${this.updateValueCallback}`)
  if (this.updateValueCallback) {
    var data = Buffer.alloc(1)
    data.writeUInt8(result, 0)
    console.log(`Calling this.updateValueCallback with ${data}`)
    this.updateValueCallback(data)
  }
}

AutoModeCharacteristic.prototype.onReadRequest = function(offset, callback) {
  console.log(`autoMode read request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = new Buffer(1);
    data.writeUInt8(this.trickler.autoMode, 0);
    callback(this.RESULT_SUCCESS, data)
  }
}


AutoModeCharacteristic.prototype.onSubscribe = function(maxValueSize, updateValueCallback) {
  console.log(`Subscribe from autoMode`)
  this.maxValueSize = maxValueSize
  this.updateValueCallback = updateValueCallback

  if (typeof this._autoModeNotifyRef === 'undefined') {
    this._autoModeNotifyRef = this.sendAutoModeNotification.bind(this)
  }
  this.trickler.on('autoMode', this._autoModeNotifyRef)
}


AutoModeCharacteristic.prototype.onUnsubscribe = function() {
  console.log(`Unsubscribe from autoMode`)
  this.maxValueSize = null
  this.updateValueCallback = null

  this.trickler.removeListener('autoMode', this._autoModeNotifyRef)
}


AutoModeCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
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
    /**
    if (typeof this._autoModeNotifyRef === 'undefined') {
      this._autoModeNotifyRef = this.sendAutoModeNotification.bind(this)
    }
    this.trickler.once('autoMode', this._autoModeNotifyRef)
    **/
    this.trickler.once('autoMode', result => {
      console.log(`autoMode result: ${result}`)
      callback(this.RESULT_SUCCESS)
    })
    this.trickler.autoMode = autoMode

    /**
    switch (autoMode) {
      case trickler.AutoModeStatus.ON:
        this.trickler.on('ready', this._autoModeNotifyRef)
        break
      case trickler.AutoModeStatus.OFF:
        this.trickler.removeListener('ready', this._autoModeNotifyRef)
        break
    }
    **/
  }
}

module.exports = AutoModeCharacteristic

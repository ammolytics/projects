/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')
const trickler = require('./trickler')


function UnitCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
    uuid: '10000003-be5f-4b43-a49f-76f2d65c6e28',
    properties: ['read', 'write', 'notify'],
    descriptors: [
      new bleno.Descriptor({
        uuid: '2901',
        value: 'Reads the current weight unit of the scale'
      })
    ]
  })

  this.trickler = trickler
}


util.inherits(UnitCharacteristic, bleno.Characteristic)


UnitCharacteristic.prototype.onReadRequest = function(offset, callback) {
  console.log(`unit read request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = Buffer.alloc(1)
    data.writeUInt8(this.trickler.unit, 0)
    callback(this.RESULT_SUCCESS, data)
  }
}


UnitCharacteristic.prototype.sendUnitNotification = function(result) {
  if (this.updateValueCallback) {
    var data = Buffer.alloc(1)
    data.writeUInt8(result, 0)
    this.updateValueCallback(data)
  }
}


UnitCharacteristic.prototype.onSubscribe = function(maxValueSize, updateValueCallback) {
  console.log(`Subscribed to unit`)
  this.maxValueSize = maxValueSize
  this.updateValueCallback = updateValueCallback

  if (typeof this._unitNotifyRef === 'undefined') {
    this._unitNotifyRef = this.sendUnitNotification.bind(this)
  }
  this.trickler.on('unit', this._unitNotifyRef)
}


UnitCharacteristic.prototype.onUnsubscribe = function() {
  console.log(`Unsubscribed from unit`)
  this.maxValueSize = null
  this.updateValueCallback = null

  this.trickler.removeListener('unit', this._unitNotifyRef)
}


UnitCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
  console.log(`unit write request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG)
  } else if (data.length !== 1) {
    callback(this.RESULT_INVALID_ATTRIBUTE_LENGTH)
  } else {
    var unit = data.readUInt8(0)
    console.log(`request to switch unit from ${this.trickler.unit} to ${unit}`)

    switch(unit) {
      case trickler.TricklerUnits.GRAINS:
      case trickler.TricklerUnits.GRAMS:
        if (this.trickler.unit === unit) {
          // Nothing to do.
          console.log('Unit already set')
          callback(this.RESULT_SUCCESS)
        } else {
          this.trickler.once('unit', result => {
            callback(this.RESULT_SUCCESS)
          })
          this.trickler.pressMode()
        }
        break
      default:
        console.log(`Invalid unit: ${unit}`)
        callback(this.RESULT_UNLIKELY_ERROR)
        break
    }
  }
}

module.exports = UnitCharacteristic

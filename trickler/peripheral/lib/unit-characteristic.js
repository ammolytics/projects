/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')
const scales = require('./and-fxfz')


class UnitCharacteristic extends bleno.Characteristic {
  constructor(scale) {
    super({
      uuid: '10000003-be5f-4b43-a49f-76f2d65c6e28',
      properties: ['read', 'write', 'notify'],
      descriptors: [
        new bleno.Descriptor({
          uuid: '2901',
          value: 'Reads the current weight unit of the scale'
        })
      ]
    })

    this.scale = scale
    this.listener = this.sendUnitNotification.bind(this)
  }


  onReadRequest (offset, callback) {
    console.log(`unit read request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG, null)
    } else {
      var data = Buffer.alloc(1)
      data.writeUInt8(this.scale.unit, 0)
      callback(this.RESULT_SUCCESS, data)
    }
  }


  sendUnitNotification (result) {
    if (this.updateValueCallback) {
      var data = Buffer.alloc(1)
      data.writeUInt8(result, 0)
      this.updateValueCallback(data)
    }
  }


  onSubscribe (maxValueSize, updateValueCallback) {
    console.log(`Subscribed to unit`)
    this.maxValueSize = maxValueSize
    this.updateValueCallback = updateValueCallback

    this.scale.on('unit', this.listener)
  }


  onUnsubscribe () {
    console.log(`Unsubscribed from unit`)
    this.maxValueSize = null
    this.updateValueCallback = null

    this.scale.removeListener('unit', this.listener)
  }


  onWriteRequest (data, offset, withoutResponse, callback) {
    console.log(`unit write request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG)
    } else if (data.length !== 1) {
      callback(this.RESULT_INVALID_ATTRIBUTE_LENGTH)
    } else {
      var unit = data.readUInt8(0)
      console.log(`request to switch unit from ${this.scale.unit} to ${unit}`)

      switch(unit) {
        case scales.UNITS.GRAINS:
        case scales.UNITS.GRAMS:
          if (this.scale.unit === unit) {
            // Nothing to do.
            console.log('Unit already set')
            callback(this.RESULT_SUCCESS)
          } else {
            this.scale.once('unit', () => {
              callback(this.RESULT_SUCCESS)
            })
            this.scale.pressMode()
          }
          break
        default:
          console.log(`Invalid unit: ${unit}`)
          callback(this.RESULT_UNLIKELY_ERROR)
          break
      }
    }
  }
}




module.exports = UnitCharacteristic

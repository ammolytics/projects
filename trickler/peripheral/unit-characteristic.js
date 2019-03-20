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
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = Buffer.alloc(1)
    data.writeUInt8(this.trickler.unit, 0)
    callback(this.RESULT_SUCCESS, data)

    this.trickler.on('ready', result => {
      if (this.updateValueCallback) {
        // Only send a notification if the value has changed.
        if (typeof this.trickler.unit === 'undefined' || this.trickler.unit !== result.unit) {
          var data = Buffer.alloc(1)
          data.writeUInt8(result.unit, 0)
          data.writeUInt8(this.trickler.unit, 0)
          this.updateValueCallback(data)
          this.trickler.emit('unit', result.unit)
        }
      }
    })
  }
}


UnitCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
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
          this.trickler.setUnit()
          this.trickler.on('unit', result => {
            // Keep pressing Mode button until correct unit is selected.
            if (unit !== result) {
              console.log('Unit still incorrect, trying again')
              this.trickler.setUnit()
            } else {
              console.log('Unit changed!')
              this.trickler.unit = result
              callback(this.RESULT_SUCCESS)
            }
          })
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

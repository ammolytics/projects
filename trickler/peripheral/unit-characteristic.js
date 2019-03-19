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
    properties: ['read', 'notify'],
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
        if (this.trickler.unit !== result.unit) {
          var data = Buffer.alloc(1)
          data.writeUInt8(result.unit, 0)
          data.writeUInt8(this.trickler.unit, 0)
          this.updateValueCallback(data)
        }
      }
    })
  }
}


module.exports = UnitCharacteristic

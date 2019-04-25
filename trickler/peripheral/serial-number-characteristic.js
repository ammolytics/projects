/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')

/**
"nknown command: "SN,15641060
*/

function SerialNumberCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
    uuid: '2a25',
    properties: ['read'],
    descriptors: [
      new bleno.Descriptor({
        uuid: '2901',
        value: 'Scale serial number'
      })
    ]
  })

  this.trickler = trickler
}


util.inherits(SerialNumberCharacteristic, bleno.Characteristic)


SerialNumberCharacteristic.prototype.onReadRequest = function(offset, callback) {
  console.log(`serial number read request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    if (typeof this.trickler.serialNumber === 'undefined') {
      this.trickler.once('serialNumber', serialNumber => {
        var data = Buffer.from(serialNumber)
        callback(this.RESULT_SUCCESS, data)
      })
      this.trickler.getSerialNumber()
    } else {
      var data = Buffer.from(this.trickler.serialNumber)
      callback(this.RESULT_SUCCESS, data)
    }
  }
}


module.exports = SerialNumberCharacteristic

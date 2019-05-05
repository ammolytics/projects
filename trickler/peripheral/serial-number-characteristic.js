/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')

/**
"nknown command: "SN,15641060
*/

class SerialNumberCharacteristic extends bleno.Characteristic {

  constructor (trickler) {
    super({
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


  onReadRequest (offset, callback) {
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
}


module.exports = SerialNumberCharacteristic

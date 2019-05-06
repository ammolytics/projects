/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')

/**
Requesting model number...
2019-03-20T16:14:48.177Z: ST, +00000.00, GN, 0, 0
"nknown command: "TN,   FX-120i
*/


class ModelNumberCharacteristic extends bleno.Characteristic {

  constructor(trickler) {
    super({
      uuid: '2a24',
      properties: ['read'],
      descriptors: [
        new bleno.Descriptor({
          uuid: '2901',
          value: 'Scale model number'
        })
      ]
    })

    this.trickler = trickler
  }


  onReadRequest (offset, callback) {
    console.log(`model number read request`)
    if (offset) {
      callback(this.RESULT_ATTR_NOT_LONG, null)
    } else {
      if (typeof this.trickler.modelNumber === 'undefined') {
        this.trickler.once('modelNumber', modelNumber => {
          var data = Buffer.from(modelNumber)
          callback(this.RESULT_SUCCESS, data)
        })
        this.trickler.getModelNumber()
      } else {
        var data = Buffer.from(this.trickler.modelNumber)
        callback(this.RESULT_SUCCESS, data)
      }
    }
  }
}


module.exports = ModelNumberCharacteristic

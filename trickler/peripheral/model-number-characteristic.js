/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')


function ModelNumberCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
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


util.inherits(ModelNumberCharacteristic, bleno.Characteristic)


ModelNumberCharacteristic.prototype.onReadRequest = function(offset, callback) {
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    this.trickler.getModelNumber()

    /**
    var data = Buffer.alloc(1)
    data.writeUInt8(this.trickler.unit, 0)
    callback(this.RESULT_SUCCESS, data)
    */

    this.trickler.on('ready', result => {
    })
  }
}


module.exports = ModelNumberCharacteristic

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')
// TOOD: Consider using mathjs.unit for storing target/current weight.
//const mathjs = require('mathjs')
const trickler = require('./trickler')


function TargetWeightCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
    uuid: '10000004-be5f-4b43-a49f-76f2d65c6e28',
    properties: ['read', 'write'],
    descriptors: [
      new bleno.Descriptor({
        uuid: '2901',
        value: 'Target powder weight'
      })
    ]
  })

  this.trickler = trickler
}


util.inherits(TargetWeightCharacteristic, bleno.Characteristic)


TargetWeightCharacteristic.prototype.onReadRequest = function(offset, callback) {
  console.log(`target weight read request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = Buffer.from(Number(this.trickler.targetWeight).toString())
    callback(this.RESULT_SUCCESS, data)
  }
}



TargetWeightCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
  console.log(`target weight write request`)
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG)
  } else if (data.length === 0) {
    callback(this.RESULT_INVALID_ATTRIBUTE_LENGTH)
  } else {
    var targetWeight = data.toString()
    console.log(`request to set the target weight from ${this.trickler.targetWeight} to ${targetWeight}`)
    this.trickler.targetWeight = targetWeight
    callback(this.RESULT_SUCCESS)
  }
}

module.exports = TargetWeightCharacteristic

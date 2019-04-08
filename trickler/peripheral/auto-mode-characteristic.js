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
    properties: ['notify', 'read', 'write'],
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


AutoModeCharacteristic.prototype.onReadRequest = function(offset, callback) {
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = new Buffer(1);
    data.writeUInt8(this.trickler.autoMode, 0);
    callback(this.RESULT_SUCCESS, data)
  }
}

AutoModeCharacteristic.prototype.autoTrickleListener = function(result) {
  if (self.updateValueCallback) {
    var weightStatus = new Buffer(1);
    weightStatus.writeUInt8(result, 0);
    self.updateValueCallback(weightStatus);
  }
}


AutoModeCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG)
  } else if (data.length === 0) {
    callback(this.RESULT_INVALID_ATTRIBUTE_LENGTH)
  } else {
    var data = new Buffer(1);
    data.writeUInt8(this.trickler.autoMode, 0);

    switch (this.trickler.autoMode) {
      case trickler.AutoModeStatus.ON:
        this.trickler.on('ready', this.autoTrickleListener)
        break
      case trickler.AutoModeStatus.OFF:
        this.trickler.removeListener('ready', this.autoTrickleListener)
        break
    }

    this.trickler.trickle(this.trickler.autoMode)
    callback(this.RESULT_SUCCESS)
  }
}

module.exports = AutoModeCharacteristic

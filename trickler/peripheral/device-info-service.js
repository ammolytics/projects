/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')

const SerialNumberCharacteristic = require('./serial-number-characteristic')
const ModelNumberCharacteristic = require('./model-number-characteristic')


function DeviceInfoService(trickler) {
  bleno.PrimaryService.call(this, {
    uuid: '180a',
    characteristics: [
      new SerialNumberCharacteristic(trickler),
      new ModelNumberCharacteristic(trickler),
    ]
  })
}


util.inherits(DeviceInfoService, bleno.PrimaryService)

module.exports = DeviceInfoService

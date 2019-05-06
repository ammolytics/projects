/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')

const SerialNumberCharacteristic = require('./serial-number-characteristic')
const ModelNumberCharacteristic = require('./model-number-characteristic')


class DeviceInfoService extends bleno.PrimaryService {
  constructor (trickler) {
    super({
      uuid: '180a',
      characteristics: [
        new SerialNumberCharacteristic(trickler),
        new ModelNumberCharacteristic(trickler),
      ]
    })
  }
}


module.exports = DeviceInfoService

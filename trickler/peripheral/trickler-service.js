/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')

const AutoModeCharacteristic = require('./auto-mode-characteristic')
const StabilityCharacteristic = require('./stability-characteristic')
const WeightCharacteristic = require('./weight-characteristic')
const UnitCharacteristic = require('./unit-characteristic')
const TargetWeightCharacteristic = require('./target-weight-characteristic')
const ModelNumberCharacteristic = require('./model-number-characteristic')
const SerialNumberCharacteristic = require('./serial-number-characteristic')


class TricklerService extends bleno.PrimaryService {
  constructor (trickler) {
    super({
      uuid: '10000000-be5f-4b43-a49f-76f2d65c6e28',
      characteristics: [
        new AutoModeCharacteristic(trickler),
        new StabilityCharacteristic(trickler),
        new WeightCharacteristic(trickler),
        new UnitCharacteristic(trickler),
        new TargetWeightCharacteristic(trickler),
        new ModelNumberCharacteristic(trickler),
        new SerialNumberCharacteristic(trickler),
      ]
    })
  }
}


module.exports = TricklerService

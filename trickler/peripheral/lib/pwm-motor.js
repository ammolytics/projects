/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const events = require('events')

const rpio = require('rpio')


/**
  if (value >= TARGET) {
    rpio.close(PIN, rpio.PIN_RESET)
  } else {
    var correction = ctrl.update(value)
    applyCorrection(correction)
  }
  */


/**
 * Speed reference.
 *
 * 4096 = 4.6875kHz = 0.213 ms
 * 2048 = 9.375kHz = 0.107 ms
 * 1024 = 18.75kHz = 0.053 ms
 * 512 = 37.5kHz = 0.0266 ms
 * 256 = 75kHz = 0.0133 ms
 * 128 = 150kHz = 0.006 ms
 * 64 = 300kHz = 0.0033 ms
 * 32 = 600.0kHz = 0.0017 ms
 * 16 = 1.2MHz = 0.00083 ms
 * 8 = 2.4MHz = 0.00042 ms
 * 4 = 4.8MHz = 0.00021 ms
 * 2 = 9.6MHz = 0.0001 ms
 * 1 = 4.6875kHz = 0.213 ms
 */



/**
 * PWM refresh rate: This is a power-of-two divisor of the base 19.2MHz rate.
 * https://github.com/jperkin/node-rpio/blob/master/src/bcm2835.h#L964-L984
 *
 * Min: 1 (2 = 9.6MHz fastest)
 * Max: 4096 (4.6875kHz slowest)
 */
var clockDiv = 1024  // As close as we can get to 0.05ms
/**
 * PWM range for a pin: This determines the maximum pulse width.
 * Note(eric): 5000 should be 500 ms wide at 0.1 ms clock div.
 */
var pulseWidth = 5000
/**
 * PWM width for a pin. This determines how much of the pulse width is ON.
 * (0/1024) = full off, (1024/1024) = full on.
 */
var pwmWidth = 3750 // 75% of 5000




var applyCorrection = (correction) => {
  //var adjust = (1 / correction) * pulseWidth
  //var adjust = pulseWidth - correction
  var adjust = pulseWidth * (1 - (1 / correction))
  console.log(`correction: ${correction}, adjust: ${adjust}`)
  rpio.pwmSetData(PIN, adjust)
}


class PwmControl extends events.EventEmitter {

  constructor (opts) {
    super()
    this.PIN = opts.pin || 12
    rpio.init({
      gpiomem: false,
      mapping: 'physical',
    })
    this.clockDiv = opts.clockDiv || 1024
    this.pulseWidth = opts.pulseWidth || 5000
    this.pmwWidth = opts.pwmWidth || 3750
  }

  open () {
    rpio.open(this.PIN, rpio.PWM)
    this.emit('open')
  }

  close () {
    rpio.close(this.PIN, rpio.PIN_RESET)
    this.emit('close')
  }

  set clockDiv (value) {
    this._clockDiv = value
    rpio.pwmSetClockDivider(this._clockDiv)
    this.emit('clockDiv', this._clockDiv)
  }

  get clockDiv () {
    return this._clockDiv
  }

  set pulseWidth (value) {
    this._pulseWidth = value
    rpio.pwmSetRange(this.PIN, this._pulseWidth)
    this.emit('pulseWidth', this._pulseWidth)
  }

  get pulseWidth () {
    return this._pulseWidth
  }

  set pwmWidth (value) {
    this._pwmWidth = value
    rpio.pwmSetData(this.PIN, this._pwmWidth)
    this.emit('pwmWidth', this._pwmWidth)
  }

  get pwmWidth () {
    return this._pwmWidth
  }
}


module.exports.PwmControl = PwmControl

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const events = require('events')

const rpio = require('rpio')


// TODO(eric): Make variable w/ frequency and duty cycle control.
// Controls the speed of the motor by pulsing it ON (true) and OFF (false) at specific intervals.
const SPEEDS = {
  VERY_SLOW: {true: 40, false: 150},
  SLOW: {true: 60, false: 100},
  MEDIUM: {true: 80, false: 100},
  FAST: {true: 100, false: 50},
  VERY_FAST: {true: 120, false: 20},
}


class MotorControl extends events.EventEmitter {

  constructor (opts) {
    super()
    opts = (typeof opts === 'object') ? opts : {}
    this.PIN = Number(opts.pin) || 15
    this._timeout = null
    this._interval = null
    this.speed = opts.speed || SPEEDS.VERY_SLOW
    this._mode = false
    this.timer = null

    this.runner = this._runner.bind(this)

    // Setup GPIO for motor control
    var rpioOpts = {
      mapping: 'physical',
    }
    if (process.env.MOCK) {
      rpioOpts.mock = 'raspi-zero-w'
    }
    rpio.init(rpioOpts)
  }

  open (cb) {
    rpio.open(this.PIN, rpio.OUTPUT, rpio.LOW)
    this.emit('open')
    if (cb) {
      cb()
    }
  }

  close (cb) {
    this.stop()
    rpio.close(this.PIN, rpio.PIN_RESET)
    this.emit('close')
    if (cb) {
      cb()
    }
  }

  get speed() {
    return this._speed
  }

  get mode () {
    return this._mode
  }

  set mode (value) {
    if (typeof value === 'boolean') {
      this._mode = value
      switch (this._mode) {
        case true:
          this.on()
          break
        case false:
          this.off()
          break
      }
    } else {
      console.error(`${value} is not a boolean`)
    }
  }

  set speed(value) {
    if (this._speed !== value) {
      console.log(`setting speed from ${this._speed} to ${JSON.stringify(value)}`)
      this._speed = value
      this.emit('speed', this._speed)
    }
  }

  _runner () {
    if (new Date() - this.timer >= this.speed[this.mode]) {
      this.mode = ! this.mode
      this.timer = new Date()
    }
  }

  off () {
    // Control motor over GPIO.
    rpio.write(this.PIN, rpio.LOW)
    this.emit('off')
  }

  on () {
    // Control motor over GPIO.
    rpio.write(this.PIN, rpio.HIGH)
    this.emit('on')
  }

  start () {
    this.timer = new Date()
    this.mode = true
    this._interval = setInterval(this.runner, 1)
    this.on()
    this.emit('start')
  }

  stop () {
    clearInterval(this._interval)
    this.timer = null
    this.mode = false
    this.off()
    this.emit('stop')
  }
}


module.exports.MotorControl = MotorControl

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const events = require('events')


const AUTO_MODES = {
  OFF: 0,
  ON: 1,
}

const RUNNING_MODES = {
  NOGO: 0,
  GO: 1,
}

const MAX_TARGET_WEIGHT = 500


class Trickler extends events.EventEmitter {
  constructor (opts) {
    super()
    opts = (typeof opts === 'object') ? opts : {}

    this.scale = opts.scale
    this.motor = opts.motor
    this._runningMode = RUNNING_MODES.NOGO
    this._autoMode = AUTO_MODES.OFF
    this._targetWeight = 0.0

    this.on('runningMode', (runningMode) => {
    })

    this.on('autoMode', (autoMode) => {
    })

    // Listen for the scale's ready event.
    this.scale.once('ready', ready => {
      this.emit('ready', ready)
    })
  }

  open (cb) {
    // Open the scale first in case it needs to warm up.
    this.scale.open(() => {
      this.motor.open(cb)
    })
  }

  close (cb) {
    this.runningMode = RUNNING_MODES.NOGO
    this.autoMode = AUTO_MODES.OFF
    // Close the motor first to ensure it turns off.
    this.motor.close(() => {
      this.scale.close(cb)
    })
  }

  start () {
  }

  stop () {
  }

  get autoMode() {
    return this._autoMode
  }

  set autoMode(value) {
    switch(value) {
      case AUTO_MODES.OFF:
      case AUTO_MODES.ON:
        if (this._autoMode !== value) {
          console.log(`setting autoMode from ${this._autoMode} to ${value}`)
          this._autoMode = value
          this.emit('autoMode', this._autoMode)
        }
        break
      default:
        console.error(`Unknown value: ${value}`)
        break
    }
  }

  get runningMode() {
    return this._runningMode
  }

  set runningMode(value) {
    switch(value) {
      case RUNNING_MODES.NOGO:
      case RUNNING_MODES.GO:
        if (this._runningMode !== value) {
          console.log(`setting runningMode from ${this._runningMode} to ${value}`)
          this._runningMode = value
          this.emit('runningMode', this._runningMode)
        }
        break
      default:
        console.error(`Unknown value: ${value}`)
        break
    }
  }

  get targetWeight() {
    return this._targetWeight
  }

  set targetWeight(value) {
    value = Number(value)
    if (value < 0 || value > MAX_TARGET_WEIGHT) {
      console.error(`Invalid target weight requested: ${value}`)
    }
    if (this._targetWeight !== value) {
      console.log(`setting targetWeight from ${this._targetWeight} to ${value}`)
      this._targetWeight = value
      this.emit('targetWeight', this._targetWeight)
    }
  }

}


module.exports.Trickler = Trickler

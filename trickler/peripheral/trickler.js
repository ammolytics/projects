/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const events = require('events')

const scales = require('./and-fxfz')
const { SPEEDS } = require('./motor')


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
    this._weightListener = this.onWeightUpdate.bind(this)

    // Listen for the scale's ready event.
    this.scale.once('ready', ready => {
      console.log(`Trickler is ready! ${ready}`)
      this.emit('ready', ready)
    })

    this.on('runningMode', runningMode => {
    })

    this.on('autoMode', autoMode => {
      switch (autoMode) {
        case AUTO_MODES.ON:
          console.log('Auto-mode activated.')
          this.scale.on('weight', this._weightListener)
          this.setMotorSpeed()
          this.startWhenReady()
          break
        case AUTO_MODES.OFF:
          this.scale.removeListener('weight', this._weightListener)
          break
      }
    })
  }

  startWhenReady () {
    // Start the motor if it isn't running and scale has been stable for over 1s.
    if (this.motor.running === false && this.scale.stableTime >= 1000) {
      this.motor.start()
    }
  }

  onWeightUpdate (weight) {
    var weightDelta = this.weightDelta()
    switch (Math.sign(weightDelta)) {
      case 0:
      case -0:
        // Exact weight.
        // Turn motor off, wait for pan removal.
        this.motor.stop()
        console.log(`EXACT WEIGHT ${weight} delta: ${weightDelta}`)
        break
      case -1:
        // Over (negative delta).
        // Turn motor off, wait for pan removal.
        this.motor.stop()
        console.log(`OVER WEIGHT ${weight} delta: ${weightDelta}`)
        break
      case 1:
        // Under (positive delta).
        console.log(`UNDER WEIGHT ${weight} delta: ${weightDelta}`)
        if (weight < 0) {
          // Pan removed.
          this.motor.stop()
          console.log('PAN REMOVED')
        } else {
          // Set the motor speed based on the current weight.
          this.setMotorSpeed()
          // Start the motor if it isn't running and scale has been stable for over 1s.
          this.startWhenReady()
        }
        break
    }
  }

  // Set appropriate motor speed based on weight delta.
  setMotorSpeed () {
    var tickDelta = this.tickDelta()

    switch (true) {
      case (tickDelta <= 2):
        this.motor.speed = SPEEDS.SINGLE_KERNEL
        break
      case (tickDelta > 2 && tickDelta <= 8):
        this.motor.speed = SPEEDS.VERY_SLOW
        break
      case (tickDelta > 8 && tickDelta <= 16):
        this.motor.speed = SPEEDS.SLOW
        break
      case (tickDelta > 16 && tickDelta <= 32):
        this.motor.speed = SPEEDS.MEDIUM
        break
      case (tickDelta > 32 && tickDelta <= 48):
        this.motor.speed = SPEEDS.FAST
        break
      case (tickDelta > 48):
        this.motor.speed = SPEEDS.VERY_FAST
        break
    }
    console.log(`Motor speed set to ${this.motor.speed}`)
  }

  // Don't bother with speeds, just turn the motor on and run until weight changes.
  prime () {
    this.motor.on()
    this.scale.once('weight', this.motor.off)
  }

  open (cb) {
    // Open the scale first in case it needs to warm up.
    this.scale.open(() => {
      this.motor.open(cb)
    })
    this.emit('open', true)
  }

  close (cb) {
    this.runningMode = RUNNING_MODES.NOGO
    this.autoMode = AUTO_MODES.OFF
    // Close the motor first to ensure it turns off.
    this.motor.close(() => {
      this.scale.close(cb)
    })
    this.emit('close', true)
  }

  start () {
    this.emit('start', true)
  }

  stop () {
    this.emit('stop', true)
  }

  // Difference between current weight and target weight.
  weightDelta () {
    return this.targetWeight - this.scale.weight
  }

  // Difference between current and target weight divided by unit precision.
  tickDelta () {
    return this.targetWeightTicks - this.scale.weightTicks
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

  get targetWeightTicks () {
    return this.targetWeight / scales.UNIT_PRECISION[this.scale.unit]
  }

}


module.exports.Trickler = Trickler
module.exports.AUTO_MODES = AUTO_MODES
module.exports.RUNNING_MODES = RUNNING_MODES
module.exports.MAX_TARGET_WEIGHT = MAX_TARGET_WEIGHT

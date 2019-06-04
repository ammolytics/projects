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
    this._interval = null
    this._autoMode = AUTO_MODES.OFF
    this._runningMode = RUNNING_MODES.NOGO
    this._targetWeight = 0.0
    this._weightListener = this.onWeightUpdate.bind(this)
    this._shouldGoBound = this.shouldGo.bind(this)
    this.startTime = null
    this.endTime = null

    // Listen for the scale's ready event.
    this.scale.once('ready', ready => {
      console.log(`Trickler is ready! ${ready}`)
      this.emit('ready', ready)
    })
    // See if it's already ready.
    if (this.scale.ready === true) {
      console.log(`Trickler is ready!`)
      this.emit('ready', true)
    }

    this.on('runningMode', runningMode => {
      switch (runningMode) {
        case RUNNING_MODES.GO:
          clearInterval(this._interval)
          this._interval = null
          this.startWhenReady()
          break
        case RUNNING_MODES.NOGO:
          // Set interval to check for ready state and set GO mode.
          if (this._interval === null) {
            console.log('NOGO set. Starting checker...')
            this._interval = setInterval(this._shouldGoBound, 50)
          }
          break
      }
    })

    this.on('autoMode', autoMode => {
      switch (autoMode) {
        case AUTO_MODES.ON:
          console.log('Auto-mode activated.')
          this.scale.on('weight', this._weightListener)
          this.setMotorSpeed()
          if (this._interval === null) {
            console.log('NOGO set. Starting checker...')
            this._interval = setInterval(this._shouldGoBound, 50)
          }
          //this.startWhenReady()
          break
        case AUTO_MODES.OFF:
          this.runningMode = RUNNING_MODES.NOGO
          this.scale.removeListener('weight', this._weightListener)
          break
      }
    })
  }

  shouldGo () {
    if (this.autoMode === AUTO_MODES.ON &&
        this.scale.weight >= 0 &&
        this.scale.stableTime >= 1000 &&
        this.tickDelta() > 1) {
      // Set GO mode.
      this.runningMode = RUNNING_MODES.GO
      console.log('Ready! Set GO mode.')
    }
  }

  startWhenReady () {
    // Start the motor if it isn't running and scale has been stable for over 1s.
    if (this.runningMode === RUNNING_MODES.GO && this.motor.running === false && this.scale.stableTime >= 1000) {
      console.log('Ready! Starting motor.')
      this.motor.start()
      this.startTime = new Date()
    }
  }

  onWeightUpdate (weight) {
    var weightDelta = this.weightDelta()
    this.endTime = new Date()
    var timeDeltaSec = (this.endTime - this.startTime) / 1000

    switch (Math.sign(weightDelta)) {
      case 0:
      case -0:
        // Exact weight.
        // Turn motor off, wait for pan removal.
        this.motor.stop()
        this.runningMode = RUNNING_MODES.NOGO
        console.log(`EXACT WEIGHT ${weight} delta: ${weightDelta}`)
        console.log(`Took ${timeDeltaSec} seconds`)
        break
      case -1:
        // Over (negative delta).
        // Turn motor off, wait for pan removal.
        this.motor.stop()
        this.runningMode = RUNNING_MODES.NOGO
        console.log(`OVER WEIGHT ${weight} delta: ${weightDelta}`)
        console.log(`Took ${timeDeltaSec} seconds`)
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
      case (tickDelta <= 3):
        this.motor.speed = SPEEDS.SINGLE_KERNEL
        break
      case (tickDelta > 3 && tickDelta <= 8):
        //this.motor.speed = SPEEDS.VERY_SLOW
        this.motor.speed = SPEEDS.SLOW
        break
      case (tickDelta > 8 && tickDelta <= 16):
        //this.motor.speed = SPEEDS.SLOW
        this.motor.speed = SPEEDS.FAST
        break
      case (tickDelta > 16 && tickDelta <= 32):
        //this.motor.speed = SPEEDS.MEDIUM
        this.motor.speed = SPEEDS.VERY_FAST
        break
      case (tickDelta > 32 && tickDelta <= 48):
        this.motor.speed = SPEEDS.VERY_FAST
        break
      case (tickDelta > 48):
        this.motor.speed = SPEEDS.VERY_FAST
        break
    }
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
    this.autoMode = AUTO_MODES.OFF
    this.runningMode = RUNNING_MODES.NOGO
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

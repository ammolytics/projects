/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const events = require('events')

const rpio = require('rpio')
const Readline = require('@serialport/parser-readline')

/**
  * Raspberry Pi: physical pin 15, BCM pin 22
  * https://pinout.xyz/pinout/pin15_gpio22
  */
const MOTOR_PIN = 15

const TricklerUnits = {
  GRAINS: 0,
  GRAMS: 1,
}

const TricklerStatus = {
  STABLE: 0,
  UNSTABLE: 1,
  OVERLOAD: 2,
  ERROR: 3,
  MODEL_NUMBER: 4,
  SERIAL_NUMBER: 5,
}

const TricklerWeightStatus = {
  UNDER: 0,
  EQUAL: 1,
  OVER: 2,
}

const TricklerMotorStatus = {
  OFF: 0,
  ON: 1,
}

const AutoModeStatus = {
  OFF: 0,
  ON: 1,
}

const RunningMode = {
  NOGO: 0,
  GO: 1,
}

const UnitMap = {
  'GN': TricklerUnits.GRAINS,
  'g': TricklerUnits.GRAMS,
}

const StatusMap = {
  'ST': TricklerStatus.STABLE,
  // Counting mode
  'QT': TricklerStatus.STABLE,
  'US': TricklerStatus.UNSTABLE,
  'OL': TricklerStatus.OVERLOAD,
  'EC': TricklerStatus.ERROR,
  'AK': TricklerStatus.ACKNOWLEDGE,
  'TN': TricklerStatus.MODEL_NUMBER,
  'SN': TricklerStatus.SERIAL_NUMBER,
}

const ErrorCodeMap = {
  'E00': 'Communications error',
  'E01': 'Undefined command error',
  'E02': 'Not ready',
  'E03': 'Timeout error',
  'E04': 'Excess characters error',
  'E06': 'Format error',
  'E07': 'Parameter setting error',
  'E11': 'Stability error',
  'E17': 'Internal mass error',
  'E20': 'Calibration weight error: The calibration weight is too heavy',
  'E21': 'Calibration weight error: The calibration weight is too light',
}

const CommandMap = {
  ID: '?ID\r\n',
  SERIAL_NUMBER: '?SN\r\n',
  MODEL_NUMBER: '?TN\r\n',
  TARE_WEIGHT: '?PT\r\n',
  CAL_BTN: 'CAL\r\n',
  OFF_BTN: 'OFF\r\n',
  ON_BTN: 'ON\r\n',
  ONOFF_BTN: 'P\r\n',
  PRINT_BTN: 'PRT\r\n',
  REZERO_BTN: 'R\r\n',
  SAMPLE_BTN: 'SMP\r\n',
  MODE_BTN: 'U\r\n',
}


const PulseSpeeds = {
  VERY_SLOW: {ON: 15, OFF: 150},
  SLOW: {ON: 20, OFF: 150},
  MEDIUM: {ON: 50, OFF: 150},
  FAST: {ON: 50, OFF: 100},
  VERY_FAST: {ON: 50, OFF: 50},
}


const MotorCtrlMap = {
  ON: rpio.HIGH,
  OFF: rpio.LOW,
}
MotorCtrlMap[TricklerMotorStatus.ON] = rpio.HIGH
MotorCtrlMap[TricklerMotorStatus.OFF] = rpio.LOW


function Trickler(port) {
  events.EventEmitter.call(this)

  // Setup GPIO for motor control
  if (process.env.MOCK) {
    rpio.init({mock: 'raspi-3'})
  }
  rpio.open(MOTOR_PIN, rpio.OUTPUT, rpio.LOW)

  // Default values.
  this._stableSince = new Date()
  this.autoMode = AutoModeStatus.OFF
  this.runningMode = RunningMode.NOGO
  this.pulseSpeed = PulseSpeeds.MEDIUM
  this.targetWeight = 0.0

  const parser = new Readline()
  // Get values from scale over serial
  this.port = port
  this.port.pipe(parser)

  parser.on('data', line => {
    var now = new Date().toISOString()
    var rawStatus = line.substr(0, 2).trim()
    var values = {
      status: StatusMap[rawStatus]
    }

    if (process.env.VERBOSE) {
      console.log(`${now}]  [${line}`)
    }

    switch (values.status) {
      case undefined:
        // Unit not ready yet.
        console.log(`Unknown command: ${line}`)
        break
      case TricklerStatus.ACKNOWLEDGE:
        console.log('Command acknowledged')
        break
      case TricklerStatus.ERROR:
        var errCode = line.substr(3, 3)
        var errMsg = ErrorCodeMap[errCode]
        console.error(`Error! code: ${errCode}, message: ${errMsg}`)
        break
      case TricklerStatus.MODEL_NUMBER:
        this.modelNumber = line.substr(3).trim()
        break
      case TricklerStatus.SERIAL_NUMBER:
        this.serialNumber = line.substr(3).trim()
        break
      default:
        var rawWeight = line.substr(3, 9).trim()
        var rawUnit = line.substr(12, 3).trim()
        values.weight = rawWeight
        values.unit = UnitMap[rawUnit]

        this.status = values.status
        this.unit = values.unit
        this.weight = values.weight
        break
    }
  })
}


util.inherits(Trickler, events.EventEmitter)


Object.defineProperties(Trickler.prototype, {
  unit: {
    get: function() {
      return this._unit
    },

    set: function(value) {
      if (this._unit !== value) {
        console.log(`Unit updated from ${this._unit} to ${value}`)
        this._unit = value
        this.emit('unit', this._unit)
      }
    }
  },

  status: {
    get: function() {
      return this._status
    },

    set: function(value) {
      if (this._status !== value) {
        this._status = value
        this.emit('status', this._status)
      }
      // Update the timestamp every time it's reported UNSTABLE.
      if (this._status !== TricklerStatus.STABLE) {
        this._stableSince = new Date()
      }
    }
  },

  weight: {
    get: function() {
      return this._weight
    },

    set: function(value) {
      if (this._weight !== value) {
        if (process.env.DEBUG) {
          console.log(`Weight updated from ${this._weight} to ${value}`)
        } 
        this._weight = value
        this.emit('weight', this._weight)
      }
    }
  },

  targetWeight: {
    get: function() {
      return this._targetWeight
    },

    set: function(value) {
      if (this._targetWeight !== value) {
        console.log(`setting targetWeight from ${this._targetWeight} to ${value}`)
        this._targetWeight = value
        this.emit('targetWeight', this._targetWeight)
      }
    }
  },

  modelNumber: {
    get: function() {
      return this._modelNumber
    },

    set: function(value) {
      console.log(`setting modelNumber from ${this._modelNumber} to ${value}`)
      if (this._modelNumber !== value) {
        this._modelNumber = value
        this.emit('modelNumber', this._modelNumber)
      }
    }
  },

  serialNumber: {
    get: function() {
      return this._serialNumber
    },

    set: function(value) {
      console.log(`setting serialNumber from ${this._serialNumber} to ${value}`)
      if (this._serialNumber !== value) {
        this._serialNumber = value
        this.emit('serialNumber', this._serialNumber)
      }
    }
  },

  autoMode: {
    get: function() {
      return this._autoMode
    },

    set: function(value) {
      console.log(`setting autoMode from ${this._autoMode} to ${value}`)
      switch(value) {
        case AutoModeStatus.OFF:
        case AutoModeStatus.ON:
          this._autoMode = value
          this.runningMode = RunningMode.NOGO
          console.log(`stableTime: ${this.stableTime()}`)
          this.trickle(value)
          break
        default:
          console.error(`Unknown value: ${value}`)
          break
      }
      this.emit('autoMode', this._autoMode)
    }
  },

  pulseSpeed: {
    get: function() {
      return this._pulseSpeed
    },

    set: function(value) {
      if (this._pulseSpeed !== value) {
        console.log(`setting pulseSpeed from ${this._pulseSpeed} to ${value}`)
        this._pulseSpeed = value
        this.emit('pulseSpeed', this._pulseSpeed)
      }
    }
  },
})


Trickler.prototype.motorOn = function() {
  // Control motor over GPIO.
  rpio.write(MOTOR_PIN, MotorCtrlMap.ON)
}

Trickler.prototype.motorOff = function() {
  // Control motor over GPIO.
  rpio.write(MOTOR_PIN, MotorCtrlMap.OFF)
}


Trickler.prototype._pulseTimeout = null


Trickler.prototype.clearPulse = function() {
  clearTimeout(this._pulseTimeout)
  this._pulseTimeout = null
}

Trickler.prototype._runFn = function() {
  this.clearPulse()
  // Prevent pulseOn from being fired until it's reset below.
  this._pulseTimeout = -1
  this.motorOn()
  this._pulseTimeout = setTimeout(this._waitFn.bind(this), this.pulseSpeed.ON)
}

Trickler.prototype._waitFn = function() {
  this.clearPulse()
  // Prevent pulseOn from being fired until it's reset below.
  this._pulseTimeout = -1
  this.motorOff()
  this._pulseTimeout = setTimeout(this._runFn.bind(this), this.pulseSpeed.OFF)
}

// Turn motor on and off at regular intervals.
Trickler.prototype.pulseOn = function() {
  // Kick off the cycle.
  this._runFn()
}

// Turns off the pulse cycle.
Trickler.prototype.pulseOff = function() {
  this.clearPulse()
  this.motorOff()
}

Trickler.prototype.stableTime = function() {
  return new Date() - this._stableSince
}

Trickler.prototype.runnerFn = function(weight) {
  var delta = this.targetWeight - weight
  console.log(`targetWeight: ${this.targetWeight}, weight: ${weight}, delta: ${delta}`)

  switch(Math.sign(delta)) {
    case 0:
    case -0:
      // Exact weight
      this.pulseOff()
      this.runningMode = RunningMode.NOGO
      console.log('exact weight reached')
      this.emit('ready', TricklerWeightStatus.EQUAL)
      break
    case -1:
      // Negative delta, over throw
      this.pulseOff()
      this.runningMode = RunningMode.NOGO
      console.log('Over throw!')
      this.emit('ready', TricklerWeightStatus.OVER)
      break
    case 1:
      // Positive delta, not finished trickling
      // If scale weight is < 0 pan is removed and motor should stay off.
      if (weight < 0) {
        console.log('Pan was removed, waiting...')
        this.pulseOff()
        this.runningMode = RunningMode.NOGO
      } else {
        if (delta <= 0.2) {
          console.log('Very slow trickle...')
          this.pulseSpeed = PulseSpeeds.VERY_SLOW
        } else if (delta <= 0.4) {
          console.log('Slow trickle...')
          this.pulseSpeed = PulseSpeeds.SLOW
        } else if (delta < 0.8) {
          console.log('Medium trickle...')
          this.pulseSpeed = PulseSpeeds.MEDIUM
        } else {
          console.log('Fast trickle...')
          this.pulseSpeed = PulseSpeeds.FAST
        }

        // If the pulse control is off turn it on.
        if (this._pulseTimeout === null) {
          this.pulseOn()
        }
      }
      break
  }
}


// When autoMode=ON, called every time weight is updated.
Trickler.prototype.trickleListener = function(weight) {
  weight = Number(weight)

  switch(this.runningMode) {
    case RunningMode.NOGO:
      // Reached EQUAL or OVER. Waiting for empty pan on scale (zero/stable).
      if (weight >= 0 && this.status === TricklerStatus.STABLE && this.stableTime() >= 2000) {
        // Turn back on after stable weight of zero for at least a second.
        console.log(`Setting mode to GO and kicking it off.`)
        this.runningMode = RunningMode.GO
        this.runnerFn(weight)
      } else {
        // give things a delayed kick to try again.
        setTimeout(() => { this.emit('weight', this.weight) }, 100)
      }
      break
    case RunningMode.GO:
      // Empty pan on scale, should trickle up.
      this.runnerFn(weight)
      break
  }

}

Trickler.prototype.trickle = function(mode) {
  // Compare weight every 10 microseconds the min allowed by setInterval)
  if (typeof this._trickleListenerRef !== 'undefined') {
    this.removeListener('weight', this._trickleListenerRef)
  }
  this.pulseOff()

  switch(mode) {
    case AutoModeStatus.ON:
      console.log('Activating trickler auto mode...')
      if (typeof this._trickleListenerRef === 'undefined') {
        this._trickleListenerRef = this.trickleListener.bind(this)
      }
      this.on('weight', this._trickleListenerRef)
      // force emit to kick things off.
      this.emit('weight', this.weight)
      break

    case AutoModeStatus.OFF:
      console.log('Deactivating trickler auto mode...')
      this.pulseOff()
      if (typeof this._trickleListenerRef !== 'undefined') {
        this.removeListener('weight', this._trickleListenerRef)
      }
      this.pulseOff()
      break
  }
}

Trickler.prototype.getModelNumber = function() {
  console.log('Requesting model number...')
  this.port.write(CommandMap.MODEL_NUMBER)
}

Trickler.prototype.getSerialNumber = function() {
  console.log('Requesting serial number...')
  this.port.write(CommandMap.SERIAL_NUMBER)
}

Trickler.prototype.pressMode = function() {
  console.log('Pressing Mode button to change unit...')
  this.port.write(CommandMap.MODE_BTN)
}

Trickler.prototype.reZero = function() {
  console.log('Pressing ReZero button...')
  this.port.write(CommandMap.REZERO_BTN)
}


module.exports.Trickler = Trickler
module.exports.TricklerUnits = TricklerUnits
module.exports.TricklerStatus = TricklerStatus
module.exports.TricklerWeightStatus = TricklerWeightStatus
module.exports.TricklerMotorStatus = TricklerMotorStatus
module.exports.AutoModeStatus = AutoModeStatus
module.exports.RunningMode = RunningMode
module.exports.UnitMap = UnitMap
module.exports.StatusMap = StatusMap
module.exports.ErrorCodeMap = ErrorCodeMap
module.exports.CommandMap = CommandMap
module.exports.PulseSpeeds = PulseSpeeds
module.exports.MotorCtrlMap = MotorCtrlMap

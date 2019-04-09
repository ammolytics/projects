/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const events = require('events')

const rpio = require('rpio')
const Readline = require('@serialport/parser-readline')

/**
  * PWM0 on the Rasp Pi, physical pin 12,  BCM pin 18
  * https://pinout.xyz/pinout/pin12_gpio18
  */
const MOTOR_PIN = 12

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
  // Default autoMode to OFF.
  this.targetWeight = 0.0
  this.autoMode = AutoModeStatus.OFF
  this.pulseSpeed = PulseSpeeds.MEDIUM
  if (process.env.MOCK) {
    rpio.init({mock: 'raspi-3'})
  }
  // Setup GPIO for motor control
  rpio.open(MOTOR_PIN, rpio.OUTPUT, rpio.LOW)

  events.EventEmitter.call(this)
  const parser = new Readline()
  // Get values from scale over serial
  this.port = port
  this.port.pipe(parser)

  parser.on('data', line => {
    var now = new Date(Date.now()).toISOString()
    var rawStatus = line.substr(0, 2).trim()
    var values = {
      status: StatusMap[rawStatus]
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

        // Make sure the unit is ready first, unit is defined.
        if (typeof values.unit !== 'undefined') {
          //console.log(`${now}: ${rawStatus}, ${rawWeight}, ${rawUnit}, ${values.status}, ${values.unit}`)
          if (typeof this.unit === 'undefined') {
            //this.unit = values.unit
          }
          //this.emit('ready', values)
        }
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
      if (this._status === TricklerStatus.UNSTABLE) {
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
      console.log(`setting targetWeight from ${this._targetWeight} to ${value}`)
      if (this._targetWeight !== value) {
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

Trickler.prototype.trickleCtrlFn = function() {
  // Compare scale weight to target weight
  var delta = this.targetWeight - this.weight
  console.log(`targetWeight: ${this.targetWeight}, weight: ${this.weight}, delta: ${delta}, this: ${this}`)
  
  switch(Math.sign(delta)) {
    case 0:
    case -0:
      // Exact weight
      this.pulseOff()
      console.log('exact weight reached')
      this.emit('ready', TricklerWeightStatus.EQUAL)
      break
    case 1:
      // Positive delta, not finished trickling
      // If scale weight is < 0 and not stable, pan is removed and motor should stay off.
      if (this.weight < 0 || (this.weight === 0 && this.stableTime() <= 200)) {
        console.log('Wait for stability...')
        this.pulseOff()
      } else {
        // If it's within one gram/grain, slow down or pulse motor.
        this.pulseOff()
        if (delta < 1.00) {
          // Turn motor on slow trickle.
          console.log('Very slow trickle...')
          this.pulseSpeed = PulseSpeeds.VERY_SLOW
          // Only turn pulse on if it's off.
          if (this.stableTime() >= 200 && this._pulseTimeout === null) {
            this.pulseOn()
          }
        } else {
          // More than one gram/grain, leave the motor on.
          if (delta < 1.5) {
            console.log('Slow trickle...')
            this.pulseSpeed = PulseSpeeds.SLOW
          } else {
            console.log('Medium trickle...')
            this.pulseSpeed = PulseSpeeds.MEDIUM
          }
          // Only turn pulse on if it's off.
          if (this._pulseTimeout === null) {
            this.pulseOn()
          }
        }
      }
      break
    case -1:
      // Negative delta, over throw
      this.pulseOff()
      console.log('Over throw!')
      this.emit('ready', TricklerWeightStatus.OVER)
      break
  }
}


// Turn motor on or off
Trickler.prototype.controlMotor = function(mode) {
  // Control motor over GPIO.
  rpio.write(MOTOR_PIN, MotorCtrlMap[mode])
}

Trickler.prototype.motorOn = function() {
  // Control motor over GPIO.
  rpio.write(MOTOR_PIN, MotorCtrlMap.ON)
}

Trickler.prototype.motorOff = function() {
  // Control motor over GPIO.
  rpio.write(MOTOR_PIN, MotorCtrlMap.OFF)
}


// Turn motor on and back off after some delay
Trickler.prototype.pulseMotor = function(delay) {
  this.motorOn()
  setTimeout(this.motorOff, delay)
}


Trickler.prototype._pulseTimeout = null


Trickler.prototype.clearPulse = function() {
  clearTimeout(this._pulseTimeout)
  this._pulseTimeout = null
}


// Turns off the pulse cycle.
Trickler.prototype.pulseOff = function() {
  this.clearPulse()
  this.motorOff()
}


// Turn motor on and off at regular intervals.
Trickler.prototype.pulseOn = function() {
  var shortFn = () => {
    this.clearPulse()
    this.motorOn()
    this._pulseTimeout = setTimeout(longFn.bind(this), this._pulseSpeed.ON)
  }

  // The long-delay function turns the motor off then calls the short-delay function.
  var longFn = () => {
    this.clearPulse()
    this.motorOff()
    this._pulseTimeout = setTimeout(shortFn.bind(this), this._pulseSpeed.OFF)
  }

  // Kick off the cycle.
  shortFn()
}

Trickler.prototype.stableTime = function() {
  return new Date() - this._stableSince
}

Trickler.prototype.trickle = function(mode) {
  // Compare weight every 10 microseconds the min allowed by setInterval)
  const TIMER = 10

  switch(mode) {
    case AutoModeStatus.ON:
      console.log('Activating trickler auto mode...')
      this._trickleInterval = setInterval(this.trickleCtrlFn.bind(this), TIMER)
      // TODO: Maybe add another listener to the input instead of using an interval?
      break

    case AutoModeStatus.OFF:
      console.log('Deactivating trickler auto mode...')
      this.pulseOff()
      clearInterval(this._trickleInterval)
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
module.exports.UnitMap = UnitMap
module.exports.StatusMap = StatusMap
module.exports.ErrorCodeMap = ErrorCodeMap
module.exports.CommandMap = CommandMap
module.exports.PulseSpeeds = PulseSpeeds
module.exports.MotorCtrlMap = MotorCtrlMap

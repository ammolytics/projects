/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
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


// Controls the speed of the motor by pulsing it ON and OFF at specific intervals.
const PulseSpeeds = {
  VERY_SLOW: {ON: 40, OFF: 150},
  SLOW: {ON: 60, OFF: 100},
  MEDIUM: {ON: 80, OFF: 100},
  FAST: {ON: 100, OFF: 50},
  VERY_FAST: {ON: 120, OFF: 20},
}


const MotorCtrlMap = {
  ON: rpio.HIGH,
  OFF: rpio.LOW,
}
MotorCtrlMap[TricklerMotorStatus.ON] = rpio.HIGH
MotorCtrlMap[TricklerMotorStatus.OFF] = rpio.LOW


class Trickler extends events.EventEmitter {
  constructor (port) {
   super()

    // Setup GPIO for motor control
    if (process.env.MOCK) {
      rpio.init({mock: 'raspi-3'})
    }
    rpio.open(MOTOR_PIN, rpio.OUTPUT, rpio.LOW)

    this.weightUpdateListener = this.onWeightUpdate.bind(this)
    this.waitFnListener = this._waitFn.bind(this)
    this.runFnListener = this._runFn.bind(this)

    // Default values.
    this._stableSince = new Date()
    this._pulseTimeout = null
    this.autoMode = AutoModeStatus.OFF
    this.runningMode = RunningMode.NOGO
    this.pulseSpeed = PulseSpeeds.MEDIUM
    this.targetWeight = 0.0

    const parser = new Readline()
    // Get values from scale over serial
    this.port = port
    this.port.pipe(parser)

    // Log any serial port errors.
    port.on('error', err => {
      console.error(`Serial Port Error: ${err.message}`)
    })

    // Listen to the serial port data stream.
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


  get unit() {
    return this._unit
  }

  set unit(value) {
    if (this._unit !== value) {
      console.log(`Unit updated from ${this._unit} to ${value}`)
      this._unit = value
      this.emit('unit', this._unit)
    }
  }

  get status() {
    return this._status
  }

  set status(value) {
    if (this._status !== value) {
      this._status = value
      this.emit('status', this._status)
    }
    // Update the timestamp every time it's reported UNSTABLE.
    if (this._status !== TricklerStatus.STABLE) {
      this._stableSince = new Date()
    }
  }

  get weight() {
    return this._weight
  }

  set weight(value) {
    if (this._weight !== value) {
      if (process.env.DEBUG) {
        console.log(`Weight updated from ${this._weight} to ${value}`)
      } 
      this._weight = value
      this.emit('weight', this._weight)
    }
  }

  get targetWeight() {
    return this._targetWeight
  }

  set targetWeight(value) {
    if (this._targetWeight !== value) {
      console.log(`setting targetWeight from ${this._targetWeight} to ${value}`)
      this._targetWeight = value
      this.emit('targetWeight', this._targetWeight)
    }
  }

  get modelNumber() {
    return this._modelNumber
  }

  set modelNumber(value) {
    console.log(`setting modelNumber from ${this._modelNumber} to ${value}`)
    if (this._modelNumber !== value) {
      this._modelNumber = value
      this.emit('modelNumber', this._modelNumber)
    }
  }

  get serialNumber() {
    return this._serialNumber
  }

  set serialNumber(value) {
    console.log(`setting serialNumber from ${this._serialNumber} to ${value}`)
    if (this._serialNumber !== value) {
      this._serialNumber = value
      this.emit('serialNumber', this._serialNumber)
    }
  }

  get autoMode() {
    return this._autoMode
  }

  set autoMode(value) {
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

  get pulseSpeed() {
    return this._pulseSpeed
  }

  set pulseSpeed(value) {
    if (this._pulseSpeed !== value) {
      console.log(`setting pulseSpeed from ${this._pulseSpeed} to ${value}`)
      this._pulseSpeed = value
      this.emit('pulseSpeed', this._pulseSpeed)
    }
  }


  motorOn () {
    // Control motor over GPIO.
    rpio.write(MOTOR_PIN, MotorCtrlMap.ON)
  }

  motorOff () {
    // Control motor over GPIO.
    rpio.write(MOTOR_PIN, MotorCtrlMap.OFF)
  }

  clearPulse () {
    clearTimeout(this._pulseTimeout)
    this._pulseTimeout = null
  }

  _runFn () {
    this.clearPulse()
    this._pulseTimeout = setTimeout(this.waitFnListener, this.pulseSpeed.ON)
    this.motorOn()
  }

  _waitFn () {
    this.clearPulse()
    this._pulseTimeout = setTimeout(this.runFnListener, this.pulseSpeed.OFF)
    this.motorOff()
  }

  // Turn motor on and off at regular intervals.
  pulseOn () {
    // Kick off the cycle.
    if (this._pulseTimeout === null && this.runningMode === RunningMode.GO) {
      this._runFn()
    }
  }

  // Turns off the pulse cycle.
  pulseOff () {
    this.clearPulse()
    this.motorOff()
  }

  stableTime () {
    return new Date() - this._stableSince
  }

  runnerFn (weight) {
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
          // Only run or adjust trickler speeds in GO mode.
          if (this.runningMode === RunningMode.GO) {
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
            this.pulseOn()
          }
        }
        break
    }
  }


  // When autoMode=ON, called every time weight is updated.
  onWeightUpdate (weight) {
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

  trickle (mode) {
    // Compare weight every 10 microseconds the min allowed by setInterval)
    this.removeListener('weight', this.weightUpdateListener)
    this.pulseOff()

    switch(mode) {
      case AutoModeStatus.ON:
        console.log('Activating trickler auto mode...')
        this.on('weight', this.weightUpdateListener)
        // force emit to kick things off.
        this.emit('weight', this.weight)
        break

      case AutoModeStatus.OFF:
        console.log('Deactivating trickler auto mode...')
        this.pulseOff()
        this.removeListener('weight', this.weightUpdateListener)
        this.pulseOff()
        break
    }
  }

  getModelNumber () {
    console.log('WRITE: Requesting model number...')
    this.port.write(CommandMap.MODEL_NUMBER, 'ascii', err => { if (err) { console.error(err) } })
  }

  getSerialNumber () {
    console.log('WRITE: Requesting serial number...')
    this.port.write(CommandMap.SERIAL_NUMBER, 'ascii', err => { if (err) { console.error(err) } })
  }

  pressMode () {
    console.log('WRITE: Pressing Mode button to change unit...')
    this.port.write(CommandMap.MODE_BTN, 'ascii', err => { if (err) { console.error(err) } })
  }

  reZero () {
    console.log('WRITE: Pressing ReZero button...')
    this.port.write(CommandMap.REZERO_BTN, 'ascii', err => { if (err) { console.error(err) } })
  }
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

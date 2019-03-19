const util = require('util')
const events = require('events')
const Readline = require('@serialport/parser-readline')

const TricklerUnits = {
  GRAINS: 0,
  GRAMS: 1,
}

const TricklerStatus = {
  STABLE: 0,
  UNSTABLE: 1,
  OVERLOAD: 2,
  ERROR: 3,
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


const parser = new Readline()

function Trickler(port) {
  events.EventEmitter.call(this)
  // TODO: get values from scale over serial
  port.pipe(parser)
  parser.on('data', line => {
    var status = line.substr(0, 2).trim()
    this.status = StatusMap[status]
    if (this.status === TricklerStatus.ERROR) {
      var errCode = line.substr(3, 3)
      var errMsg = ErrorCodeMap[errCode]
      console.error(`Error! code: ${errCode}, message: ${errMsg}`)
    } else {
      var value = line.substr(3, 9).trim()
      var unit = line.substr(12, 3).trim()
      var now = new Date(Date.now()).toISOString()
      console.log(`${now}: ${status}, ${value}, ${unit}`)

      this.unit = UnitMap[unit]
      this.value = value
      console.log(`${this.status}, ${this.unit}`)
    }
  })
}


util.inherits(Trickler, events.EventEmitter)


Trickler.prototype.trickle = function(weight) {
  var self = this
  console.log('Running trickler...')
  // TODO: Send commands over serial, monitor status.
}


module.exports.Trickler = Trickler
module.exports.TricklerUnits = TricklerUnits
module.exports.TricklerStatus = TricklerStatus
module.exports.TricklerWeightStatus = TricklerWeightStatus
module.exports.TricklerMotorStatus = TricklerMotorStatus

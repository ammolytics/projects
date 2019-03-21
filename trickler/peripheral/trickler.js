/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
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



function Trickler(port) {
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
        console.log(`Unknown command: "${line}"`)
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
        var modelNumber = line.substr(3).trim()
        this.emit('modelNumber', modelNumber)
        break
      case TricklerStatus.SERIAL_NUMBER:
        var serialNumber = line.substr(3).trim()
        this.emit('serialNumber', serialNumber)
        break
      default:
        if (typeof this.status === 'undefined') {
          this.status = values.status
        }
        var rawWeight = line.substr(3, 9).trim()
        var rawUnit = line.substr(12, 3).trim()
        values.weight = rawWeight
        values.unit = UnitMap[rawUnit]
        // Make sure the unit is ready first, unit is defined.
        if (typeof values.unit !== 'undefined') {
          //console.log(`${now}: ${rawStatus}, ${rawWeight}, ${rawUnit}, ${values.status}, ${values.unit}`)
          if (typeof this.unit === 'undefined') {
            this.unit = values.unit
          }
          this.emit('ready', values)
        }
        break
    }
  })
}


util.inherits(Trickler, events.EventEmitter)


Trickler.prototype.trickle = function(weight) {
  console.log('Running trickler...')
  // TODO: Send commands over serial, monitor status.
}

Trickler.prototype.getModelNumber = function() {
  console.log('Requesting model number...')
  this.port.write('?TN\r\n')
}

Trickler.prototype.getSerialNumber = function() {
  console.log('Requesting serial number...')
  this.port.write('?SN\r\n')
}

Trickler.prototype.pressMode = function() {
  console.log('Pressing Mode button to change unit...')
  this.port.write('U\r\n')
}

Trickler.prototype.reZero = function() {
  console.log('Pressing ReZero button...')
  this.port.write('R\r\n')
}


module.exports.Trickler = Trickler
module.exports.TricklerUnits = TricklerUnits
module.exports.TricklerStatus = TricklerStatus
module.exports.TricklerWeightStatus = TricklerWeightStatus
module.exports.TricklerMotorStatus = TricklerMotorStatus

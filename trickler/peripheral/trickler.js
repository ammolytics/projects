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


const parser = new Readline()

function Trickler(port) {
  events.EventEmitter.call(this)
  // TODO: get values from scale over serial
  port.pipe(parser)
  parser.on('data', line => {
    var status = line.substr(0, 2).trim()
    var value = line.substr(3, 0).trim()
    var unit = line.substr(13, 2).trim()
    var now = new Date(Date.now()).toISOString()
    console.log(`${now}: ${status}, ${value}, ${unit}`)
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

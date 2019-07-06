const rpio = require('rpio')
const scales = require('./and-fxfz')
const Controller = require('./pid')
const pwm = require('./pwm')

const TARGET = process.env.TARGET
const PIN = process.env.PIN

const ctrl = new Controller({
  k_p: 2,
  k_i: 0.0,
  k_d: 2,
})

// TODO: Not using target weight yet.
//ctrl.setTarget(TARGET)

const scale = new scales.Scale({})
scale.open()

const motor = new pwm.PwmControl({
  pin: PIN,
})


// TODO: Measure how much powder trickles at top speed.
function measure () {
  var readings = []
  // Set top speed.
  var oldSpeed = motor.pwmWidth
  motor.pwmWidth = motor.pulseWidth

  scale.on('weight', weight => {
    readings.push({
      timestamp: new Date(),
      weight: weight,
    })
  })
  var start = null

  // Set timer to stop process.
  var stopFn = () => {
    motor.close()
    scale.close()
    console.dir(readings)

    var first = readings[0]
    var last = readings[readings.length - 1]
    console.log(`${last.weight - first.weight} over ${last.timestamp - first.timestamp} ms`)
    console.log(`first reading after ${first.timestamp - start} ms`)
  }

  motor.open()
  start = new Date()
  setTimeout(stopFn, 10000)
}

measure()






// Graceful shutdown.
var shutdown = () => {
  console.log('Shutting down...')
  motor.close()
  scale.close(() => {
    console.log('Graceful shutdown complete.')
    process.exit(0)
  })
}

// Graceful shutdown.
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

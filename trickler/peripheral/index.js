/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const bleno = require('bleno')

const motors = require('./motor')
const scales = require('./and-fxfz')
const trickler = require('./trickler')
const DeviceInfoService = require('./device-info-service')
const TricklerService = require('./trickler-service')

console.log('===== STARTING UP =====')

const MOTOR = new motors.MotorControl({
  pin: process.env.MOTOR_PIN,
})
const SCALE = new scales.Scale({
  baud: process.env.SCALE_BAUD_RATE,
  device: process.env.SCALE_DEVICE_PATH,
})
const TRICKLER = new trickler.Trickler({
  motor: MOTOR,
  scale: SCALE,
})

const errHandler = (err) => {
  if (err) {
    console.error(err)
  }
}

TRICKLER.once('ready', () => {
  console.log(`Scale weight reads: ${SCALE.weight} ${SCALE.unit}, stableTime: ${TRICKLER.stableTime}`)
  // Kick off bluetooth after trickler reports it's ready.
  bleno.on('stateChange', state => {
    console.log(`on -> stateChange: ${state}`)
    switch (state) {
      case 'poweredOn':
        bleno.startAdvertising(process.env.DEVICE_NAME, [TricklerService.TRICKLER_SERVICE_UUID], errHandler)
        break
      case 'unknown':
      case 'resetting':
      case 'unsupported':
      case 'unauthorized':
      case 'poweredOff':
      default:
        bleno.stopAdvertising()
        break
    }
  })
})


bleno.on('advertisingStart', err => {
  console.log('on -> advertisingStart: ' + (err ? 'error ' + err : 'success'))
  if (err) {
    // Error handled by advertisingStartError
    return
  }

  console.log('advertising services...')
  bleno.setServices([
    INFO_SERVICE,
    TRICKLER_SERVICE,
  ])
})

bleno.on('advertisingStop', () => {
  console.log('on -> advertisingStop')
  TRICKLER.close()
})

bleno.on('advertisingStartError', err => {
  console.log('on -> advertisingStartError: ' + (err ? 'error ' + err : 'success'))
})

bleno.on('accept', clientAddress => {
  console.log(`Client accepted: ${clientAddress}`)
})

bleno.on('disconnect', clientAddress => {
  console.log(`Client disconnected: ${clientAddress}`)
})

console.log('Opening trickler...')
TRICKLER.open()

const INFO_SERVICE = new DeviceInfoService(TRICKLER)
const TRICKLER_SERVICE = new TricklerService.Service(TRICKLER)


/**
 * Graceful shutdown
 */
const shutdown = () => {
  // Close the trickler, scale, and motor.
  TRICKLER.close(() => {
    process.exit(0)
  })
}

process.on('SIGINT', shutdown)
process.on('SIGTERM', shutdown)

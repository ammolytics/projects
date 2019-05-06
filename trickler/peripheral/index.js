/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')
const SerialPort = require('serialport')

const trickler = require('./trickler')
const DeviceInfoService = require('./device-info-service')
const TricklerService = require('./trickler-service')

console.log('===== STARTING UP =====')

// The last argument passed in should be the device path (e.g. /dev/ttyUSB0)
let devPath = process.argv[process.argv.length - 1]
const BAUD_RATE = 19200
const PERIPHERAL_NAME = 'Trickler'

console.log(`Device: ${devPath}`)

// Create mock binding if env MOCK is set.
if (process.env.MOCK) {
  console.log('Using Mock interface')
  const MockScale = require('./mock-scale')
  SerialPort.Binding = MockScale
  // Create a port and enable the echo and recording.
  MockScale.createPort(devPath, { echo: true, record: true })
}

console.log('Scanning for USB devices...')
SerialPort.list().then(
  ports => ports.forEach(p => {
    console.log(`device: ${p.comName}`)
    // TODO: Add checks to ensure this is the right USB device. Don't assume just one.
    if (p.comName.indexOf('ttyUSB') !== -1) {
      createSerialPort(p.comName)
    }
  }),
  err => console.error(err)
)

function createSerialPort(devicePath) {
  console.log(`Connecting to ${devicePath}...`)
  const port = new SerialPort(devicePath, { baudRate: BAUD_RATE }, err => {
    if (err) {
      console.log(`SERIAL PORT ERROR: ${err.message}`)
    }
  })

  runService(port)
}


function runService (port) {
  console.log('PORT')
  console.log(port)
  var TRICKLER = new trickler.Trickler(port)
  var deviceInfoService = new DeviceInfoService(TRICKLER)
  var service = new TricklerService(TRICKLER)

  //
  // Wait until the BLE radio powers on before attempting to advertise.
  // If you don't have a BLE radio, then it will never power on!
  //
  bleno.on('stateChange', function(state) {
    console.log(`on -> stateChange: ${state}`)
    if (state === 'poweredOn') {
      bleno.startAdvertising(PERIPHERAL_NAME, [service.uuid], function(err) {
        if (err) {
          console.log(err)
        }
      })
    } else {
      bleno.stopAdvertising()
    }
  })


  bleno.on('advertisingStart', function(err) {
    console.log('on -> advertisingStart: ' + (err ? 'error ' + err : 'success'))
    if (!err) {
      console.log('advertising...')
      bleno.setServices([
        deviceInfoService,
        service
      ])

      console.log(`Trickler weight reads: ${TRICKLER.weight}, stableTime: ${TRICKLER.stableTime()}`)
      // If weight is undefined, consider it a failure and restart.
      if (typeof TRICKLER._weight === 'undefined') {
        console.error(`Probably failure.  weight: ${TRICKLER.weight}, unit: ${TRICKLER.unit}, stableTime: ${TRICKLER.stableTime()}`)
        // TODO: Limit the number of restarts w/ environment variable.
        console.log('FORCED RESTART')
        var path = port.path
        port.close(() => {
          createSerialPort(path)
        })
      }
    }
  })

  bleno.on('advertisingStop', function() {
    console.log('on -> advertisingStop')
  })

  bleno.on('advertisingStartError', function(err) {
    console.log('on -> advertisingStartError: ' + (err ? 'error ' + err : 'success'))
  })

  bleno.on('accept', function(clientAddress) {
    console.log(`Client accepted: ${clientAddress}`)
  })

  bleno.on('disconnect', function(clientAddress) {
    console.log(`Client disconnected: ${clientAddress}`)
  })
}

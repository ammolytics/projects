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

// The last argument passed in should be the device path (e.g. /dev/ttyUSB0)
const devPath = process.argv[process.argv.length - 1]
const BAUD_RATE = 19200

console.log(`Device: ${devPath}`)

// Create mock binding if env MOCK is set.
if (process.env.MOCK) {
  console.log('Using Mock interface')
  const MockScale = require('./mock-scale')
  SerialPort.Binding = MockScale
  // Create a port and enable the echo and recording.
  MockScale.createPort(devPath, { echo: true, record: true })
}

const port = new SerialPort(devPath, { baudRate: BAUD_RATE })
const PERIPHERAL_NAME = 'Trickler'
const TRICKLER = new trickler.Trickler(port)

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


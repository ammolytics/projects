/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const util = require('util')
const bleno = require('bleno')
const SerialPort = require('serialport')

const trickler = require('./trickler')
const TricklerService = require('./trickler-service')

// Create mock binding if env MOCK is set.
if (process.env.MOCK) {
  console.log('Using Mock interface')
  const MockScale = require('./mock-scale')
  SerialPort.Binding = MockScale
  // Create a port and enable the echo and recording.
  MockScale.createPort('/dev/ttyUSB0', { echo: true, record: true })
}

const port = new SerialPort('/dev/ttyUSB0', { baudRate: 19200 })
const PERIPHERAL_NAME = 'Trickler'

var service = new TricklerService(new trickler.Trickler(port))

//
// Wait until the BLE radio powers on before attempting to advertise.
// If you don't have a BLE radio, then it will never power on!
//
bleno.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    //
    // We will also advertise the service ID in the advertising packet,
    // so it's easier to find.
    //
    bleno.startAdvertising(PERIPHERAL_NAME, [service.uuid], function(err) {
      if (err) {
        console.log(err);
      }
    });
  }
  else {
    bleno.stopAdvertising();
  }
})


bleno.on('advertisingStart', function(err) {
  if (!err) {
    console.log('advertising...');
    //
    // Once we are advertising, it's time to set up our services,
    // along with our characteristics.
    //
    bleno.setServices([
      service
    ]);
  }
})

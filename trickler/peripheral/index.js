const util = require('util')
const bleno = require('bleno')
const SerialPort = require('serialport')

const trickler = require('./trickler')
const TrickerService = require('./trickler-service')

const port = new SerialPort('/dev/ttyUSB0', { baudRate: 19200 })
cont PERIPHERAL_NAME = 'Trickler'

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
    bleno.startAdvertising(name, [service.uuid], function(err) {
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

const util = require('util')
const bleno = require('bleno')
const trickler = require('./trickler')


function TricklerWeightCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
    uuid: '',
    properties: ['notify'],
    descriptors: [
      new bleno.Descriptor({
        uuid: '',
        value: ''
      })
    ]
  })

  this.trickler = trickler
}


util.inherits(TricklerWeightCharacteristic, bleno.Characteristic)


TricklerWeightCharacteristic.prototype.onReadRequest = function(offset, callback) {
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    var data = new Buffer(1)
    data.writeUInt8(this.trickler.weight, 0)
    callback(this.RESULT_SUCCESS, data)
  }
}



parser.on('data', line => console.log(`> ${line}`))

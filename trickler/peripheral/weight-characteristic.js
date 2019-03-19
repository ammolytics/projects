const util = require('util')
const bleno = require('bleno')
const trickler = require('./trickler')


function WeightCharacteristic(trickler) {
  bleno.Characteristic.call(this, {
    uuid: '10000001-be5f-4b43-a49f-76f2d65c6e28',
    properties: ['read', 'notify'],
    descriptors: [
      new bleno.Descriptor({
        uuid: '2901',
        value: 'Reads the current weight value of the scale'
      })
    ]
  })

  this.trickler = trickler
}


util.inherits(WeightCharacteristic, bleno.Characteristic)


WeightCharacteristic.prototype.onReadRequest = function(offset, callback) {
  if (offset) {
    callback(this.RESULT_ATTR_NOT_LONG, null)
  } else {
    this.trickler.on('ready', result => {
      if (this.updateValueCallback) {
        var data = Buffer.from(Number(weight).toString())
        this.updateValueCallback(data)
      }
    })
    callback(this.RESULT_SUCCESS, data)
  }
}


module.exports = WeightCharacteristic

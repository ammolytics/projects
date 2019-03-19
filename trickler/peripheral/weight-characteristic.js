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
    var data = Buffer.from(Number(this.trickler.weight).toString())
    callback(this.RESULT_SUCCESS, data)

    this.trickler.on('ready', result => {
      if (this.updateValueCallback) {
        // Only send a notification if the value has changed.
        if (this.trickler.weight !== result.weight) {
          this.trickler.weight = result.weight
          this.updateValueCallback(Buffer.from(Number(result.weight).toString()))
        }
      }
    })
  }
}


module.exports = WeightCharacteristic

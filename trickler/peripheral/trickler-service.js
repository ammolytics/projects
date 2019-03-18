const util = require('util')
const bleno = require('bleno')

// TODO: List characteristics.


function TricklerService(trickler) {
  bleno.PrimaryService.call(this, {
    uuid: '09b79ad7-be5f-4b43-a49f-76f2d65c6e28',
    characteristics: [
    ]
  })
}


util.inherits(TricklerService, bleno.PrimaryService)


module.exports = TricklerService

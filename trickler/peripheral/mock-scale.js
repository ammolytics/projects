const MockBinding = require('@serialport/binding-mock')


class MockScale extends MockBinding {
  constructor(opt) {
    super(opt)

    var delay = 50
    this.interval = setInterval(() => {
      this.emitData('ST,+00000.00 GN\r\n')
    }, delay)
  }
}

module.exports = MockScale

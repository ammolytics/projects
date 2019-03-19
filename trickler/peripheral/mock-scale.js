/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
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

/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const MockBinding = require('@serialport/binding-mock')
const trickler = require('./trickler')


function randomInt() {
  return Math.floor(Math.random() * Math.floor(10))
}


class MockScale extends MockBinding {
  constructor(opt) {
    super(opt)

    this._delay = 50
    this._unit = trickler.TricklerUnits.GRAINS
    this._interval = setInterval(this._grainFn.bind(this), this._delay)

    // For a given command, the mock should respond accordingly.
    var commands = {}
    commands[trickler.CommandMap.MODE_BTN] = this.modeBtnAction.bind(this)

    // Command runnner
    var commander = () => {
      if (!this.lastWrite) {
        return
      }
      var last = this.lastWrite.toString()
      var cmd = commands[last]
      this.lastWrite = null
      if (!cmd) {
        return
      }
      cmd()
    }

    // Check for a new command every 10 ms.
    setInterval(commander, 10)
  }

  // Act like the mode button was pressed, change units.
  modeBtnAction() {
    console.log('running mode btn')
    clearInterval(this._interval)
    switch (this._unit) {
      case trickler.TricklerUnits.GRAINS:
        this._unit = trickler.TricklerUnits.GRAMS
        this._interval = setInterval(this._gramFn.bind(this), this._delay)
        break
      case trickler.TricklerUnits.GRAMS:
        this._unit = trickler.TricklerUnits.GRAINS
        this._interval = setInterval(this._grainFn.bind(this), this._delay)
        break
    }
  }

  // Return a random reading in grains.
  _grainFn() {
    var randomVal = [
      '000',
      randomInt(),
      randomInt(),
      '.',
      randomInt(),
      randomInt(),
    ].join('')
    this.emitData(`ST,+${randomVal} GN\r\n`)
  }

  // Return a random reading in grams.
  _gramFn() {
    var randomVal = [
      '0',
      randomInt(),
      randomInt(),
      randomInt(),
      '.',
      randomInt(),
      randomInt(),
      randomInt(),
    ].join('')

    this.emitData(`ST,+${randomVal}  g\r\n`)
  }
}

module.exports = MockScale

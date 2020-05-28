/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
const MockBinding = require('@serialport/binding-mock')
const trickler = require('./trickler')


/**
function randomInt() {
  return Math.floor(Math.random() * Math.floor(10))
}
*/

function formatGrams(numVal) {
  return numVal.toFixed(3).padStart(7, 0)
}

function formatGrains(numVal) {
  // Scale can only display 0.02 GN.
  if(numVal.toFixed(2).substr(-1) % 2) {
    numVal = numVal += 0.01
  }
  return numVal.toFixed(2).padStart(6, 0)
}

/**
function addPan() {
  `
  019-04-19T22:57:11.559Z]  [ST,+00000.00 GN
  2019-04-19T22:57:11.606Z]  [ST,+00000.00 GN
  2019-04-19T22:57:11.654Z]  [ST,+00000.00 GN
  2019-04-19T22:57:11.702Z]  [US,+00001.96 GN
  2019-04-19T22:57:11.749Z]  [US,+00010.74 GN
  2019-04-19T22:57:11.797Z]  [US,+00033.76 GN
  2019-04-19T22:57:11.845Z]  [US,+00076.88 GN
  2019-04-19T22:57:11.892Z]  [US,+00142.92 GN
  2019-04-19T22:57:11.940Z]  [US,+00228.52 GN
  2019-04-19T22:57:11.987Z]  [US,+00321.68 GN
  2019-04-19T22:57:12.035Z]  [US,+00407.32 GN
  2019-04-19T22:57:12.083Z]  [US,+00474.86 GN
  2019-04-19T22:57:12.130Z]  [US,+00522.52 GN
  2019-04-19T22:57:12.179Z]  [US,+00558.40 GN
  2019-04-19T22:57:12.227Z]  [US,+00593.12 GN
  2019-04-19T22:57:12.274Z]  [US,+00630.44 GN
  2019-04-19T22:57:12.322Z]  [US,+00666.70 GN
  2019-04-19T22:57:12.370Z]  [US,+00695.12 GN
  2019-04-19T22:57:12.417Z]  [US,+00711.08 GN
  2019-04-19T22:57:12.465Z]  [US,+00716.64 GN
  2019-04-19T22:57:12.513Z]  [US,+00717.54 GN
  2019-04-19T22:57:12.560Z]  [US,+00717.58 GN
  2019-04-19T22:57:12.609Z]  [US,+00717.58 GN
  2019-04-19T22:57:12.658Z]  [US,+00717.58 GN
  2019-04-19T22:57:12.706Z]  [US,+00717.58 GN
  2019-04-19T22:57:12.753Z]  [US,+00717.58 GN
  2019-04-19T22:57:12.802Z]  [US,+00717.60 GN
  2019-04-19T22:57:12.850Z]  [US,+00717.60 GN
  2019-04-19T22:57:12.897Z]  [US,+00717.60 GN
  2019-04-19T22:57:12.945Z]  [ST,+00717.60 GN
  2019-04-19T22:57:12.993Z]  [ST,+00717.60 GN
  `
}

function zeroPan() {
  `2019-04-19T22:57:14.762Z]  [ST,+00717.60 GN
2019-04-19T22:57:14.810Z]  [ST,+00717.60 GN
2019-04-19T22:57:16.053Z]  [ST,+00000.00 GN
2019-04-19T22:57:16.100Z]  [ST,+00000.00 GN
2019-04-19T22:57:16.148Z]  [ST,+00000.00 GN
2019-04-19T22:57:16.195Z]  [ST,+00000.00 GN
2019-04-19T22:57:16.243Z]  [ST,+00000.00 GN`
}

function removePan() {
  `2019-04-19T22:57:03.239Z]  [ST,+00000.00 GN
2019-04-19T22:57:03.288Z]  [ST,+00000.00 GN
2019-04-19T22:57:03.334Z]  [US,+00001.02 GN
2019-04-19T22:57:03.382Z]  [US,+00003.32 GN
2019-04-19T22:57:03.429Z]  [US,-00000.72 GN
2019-04-19T22:57:03.477Z]  [US,-00030.78 GN
2019-04-19T22:57:03.525Z]  [US,-00106.12 GN
2019-04-19T22:57:03.572Z]  [US,-00228.46 GN
2019-04-19T22:57:03.623Z]  [US,-00378.10 GN
2019-04-19T22:57:03.670Z]  [US,-00521.36 GN
2019-04-19T22:57:03.718Z]  [US,-00627.58 GN
2019-04-19T22:57:03.765Z]  [US,-00686.72 GN
2019-04-19T22:57:03.813Z]  [US,-00710.30 GN
2019-04-19T22:57:03.861Z]  [US,-00716.48 GN
2019-04-19T22:57:03.908Z]  [US,-00717.38 GN
2019-04-19T22:57:03.957Z]  [US,-00717.48 GN
2019-04-19T22:57:04.005Z]  [US,-00717.54 GN
2019-04-19T22:57:04.052Z]  [US,-00717.58 GN
2019-04-19T22:57:04.100Z]  [US,-00717.60 GN
2019-04-19T22:57:04.148Z]  [US,-00717.60 GN
2019-04-19T22:57:04.195Z]  [US,-00717.62 GN
2019-04-19T22:57:04.243Z]  [US,-00717.62 GN
2019-04-19T22:57:04.290Z]  [US,-00717.62 GN
2019-04-19T22:57:04.338Z]  [US,-00717.62 GN
2019-04-19T22:57:04.387Z]  [US,-00717.62 GN
2019-04-19T22:57:04.435Z]  [ST,-00717.60 GN
2019-04-19T22:57:04.482Z]  [ST,-00717.60 GN`
}
*/


/**
{
  ON: () => {
    function trickleUp () {
      var value = 0
      var amount = 0.02
      var rate = 10
      var i = null
      i = setInterval(() => { value += amount; this.emitData() }, rate)
      this.on('ready', () => { clearInterval(1) })
    }
    setTimeout(trickleUp, 500)
  },
  OFF: () => {
  },
}
*/

/**
  * Wait until scale is stable and 0.
  * If automode is on, start to trickle up, increase weight.
  * Jump in weight (80% or target - 2 gr) to simulate a dump.
  * Once target weight is reached, let the app take over.
  * Wait a second or two, then drop down to a negative weight (pan removed)
  * Wait another second, then go back up to zero.
  * Start pretend trickling again.
function fakeUser() {
    this.emitData(`US,+000.000  g\r\n`)
    this.emitData(`ST,+000.000  g\r\n`)
    this.emitData(`US,+000.00  GN\r\n`)
    this.emitData(`ST,+000.00  GN\r\n`)

    this.emitData(`US,-046.500  g\r\n`)
    this.emitData(`ST,-046.500  g\r\n`)
    this.emitData(`US,-717.60  GN\r\n`)
    this.emitData(`ST,-717.60  GN\r\n`)

    this.emitData(`US,+000.000  g\r\n`)
    this.emitData(`ST,+000.000  g\r\n`)
    this.emitData(`US,+000.00  GN\r\n`)
    this.emitData(`ST,+000.00  GN\r\n`)

    this.on('autoMode', (mode) => {
      switch (mode) {
        case AutoModeStatus.ON:
          break
        case AutoModeStatus.OFF:
          break
      }
    })
}
*/


class MockScale extends MockBinding {
  constructor(opt) {
    super(opt)

    this._delay = 50
    this._unit = trickler.TricklerUnits.GRAINS
    this._currentWeight = 0
    this._tareWeight = 0

    // For a given command, the mock should respond accordingly.
    var commands = {}
    commands[trickler.CommandMap.MODE_BTN] = this.modeBtnAction.bind(this)
    commands[trickler.CommandMap.REZERO_BTN] = this.rezeroBtnAction.bind(this)

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
    // emit weight every 50 ms.
    setInterval(this._printWeight.bind(this), 50)
  }

  // Add or remove weight from the scale.
  changeWeight(weight) {
    this._currentWeight = weight
  }

  getCurrentWeight() {
    return this._currentWeight - this._tareWeight
  }

  rezeroBtnAction() {
    console.log('Rezeroing the scale')
    this._tareWeight = this._currentWeight 
  }

  // Act like the mode button was pressed, change units.
  modeBtnAction() {
    console.log('Toggling scale mode/unit')
    this._unit = trickler.TricklerUnits.GRAINS === this._unit ? trickler.TricklerUnits.GRAMS : trickler.TricklerUnits.GRAINS
  }

  _printWeight() {
    var sign = Math.sign(this.getCurrentWeight())
    var unit = null
    var weight = null

    switch(this._unit) {
      case trickler.TricklerUnits.GRAINS:
        unit = 'GN'
        weight = formatGrains(sign * this.getCurrentWeight())
        break
      case trickler.TricklerUnits.GRAMS:
        unit = ' g'
        weight = formatGrams(sign * this.getCurrentWeight())
        break
    }

    this.emitData(`ST,${sign}${weight} ${unit}\r\n`)
  }
}

module.exports = MockScale

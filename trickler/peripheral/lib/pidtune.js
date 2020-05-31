const scales = require('./and-fxfz')
const pwm = require('./pwm')


function start (PWM, SCALE, timerFn, fn, target) {
  SCALE.on('weight', fn)
  console.log('timestamp, input (motor %), output (%)')
  PWM.duty = .40
  timerFn = timer.bind(null, Date.now())
  console.log(`${timerFn()}, ${PWM.duty.toFixed(2)}, ${(SCALE.weight / target).toFixed(2)}`)
}

function finish (PWM, SCALE) {
  PWM.off()
  // Turn everything else off after some time to keep collecting data from overflow.
  setTimeout(() => {
    SCALE.removeAllListeners('weight')
    SCALE.close()
    PWM.close()
  }, 2000)
}

function timer(start) {
  return ((Date.now() - start) / 1000).toFixed(3)
}

function run (target) {
  const PWM = new pwm.PwmControl({pwmWidth: 0, clockDiv: 256})
  const SCALE = new scales.Scale({baud:19200, device: '/dev/ttyUSB0'})
  var timerFn = timer.bind(null, Date.now())

  function update (weight) {
    console.log(`${timerFn()}, ${PWM.duty.toFixed(2)}, ${(weight / target).toFixed(2)}`)
    var doneness = parseInt(weight / target * 100)
    switch (doneness) {
      case 100:
        finish(PWM, SCALE)
        break;
      case 70:
        PWM.duty = .90
        break;
      case 50:
        PWM.duty = .50
        break;
      case 20:
        PWM.duty = .70
        break;
      default:
        if (doneness >= 100) {
          finish(PWM, SCALE)
        }
    }
  }

  SCALE.open(() => PWM.open(() => {setTimeout(start.bind(null, PWM, SCALE, timerFn, update, target), 1000)}))
}

module.exports.run = run


/**
      case 100:
        finish()
        break;
      case 99:
        PWM.duty = .30
        break;
      case 97:
        PWM.duty = .40
        break;
      case 90:
        PWM.duty = .50
        break;
      case 80:
        PWM.duty = .80
        break;
      case 50:
        PWM.duty = .90
        break;
      default:
        if (doneness >= 100) {
          finish()
        }
**/


/**
      case 100:
        finish()
        break;
      case 70:
        PWM.duty = .90
        break;
      case 50:
        PWM.duty = .30
        break;
      case 20:
        PWM.duty = .60
        break;
      default:
        if (doneness >= 100) {
          finish()
        }
**/


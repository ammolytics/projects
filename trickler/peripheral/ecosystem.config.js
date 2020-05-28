module.exports = {
  apps : [{
    name: 'opentrickler',
    script: './index.js',
    cwd: '/home/pi/projects/trickler/peripheral/',
    args: '/dev/ttyUSB0',
    instances: 1,
    watch: false,
    log_date_format: 'YYYY-MM-DD HH:mm:ss.SSS Z',
    env: {
      'NODE_ENV': 'development',
      // NOTE(eric): Pin 15 was originally used but pin 12 is now recommended.
      // 15 for fake PWM.
      //'MOTOR_PIN': 15,
      // 12 for real PWM.
      'MOTOR_PIN': 12,
      'SCALE_BAUD_RATE': 19200,
      'SCALE_DEVICE_PATH': '/dev/ttyUSB0',
      'DEVICE_NAME': 'Trickler',
      'BLENO_DEVICE_NAME': 'Trickler',
      'BLENO_ADVERTISING_INTERVAL': 50,
      //'DEBUG': 'bleno',
    },
    env_production : {
       'NODE_ENV': 'production',
    }
  }]
}

module.exports = {
  apps : [{
    name: 'opentrickler',
    script: './index.js',
    cwd: '/home/pi/projects/trickler/peripheral/',
    args: '/dev/ttyUSB0',
    instances: 1,
    watch: true,
    wait_ready: true,
    listen_timeout: 10000,
    log_date_format: 'YYYY-MM-DD HH:mm Z',
    env: {
      'NODE_ENV': 'development',
    },
    env_production : {
       'NODE_ENV': 'production'
    }
  }]
}

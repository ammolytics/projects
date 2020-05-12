#!/usr/bin/env node


// Parse the config file to load env vars before starting the application.
var config = require('./' + process.argv[2])

for (var k in config.apps[0].env) {
  console.log('Setting: process.env[', k, '] = ', config.apps[0].env[k])
  process.env[k] = config.apps[0].env[k]
}


require('./index.js')

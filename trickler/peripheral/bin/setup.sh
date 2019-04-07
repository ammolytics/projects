#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX";
  xcode-select --install;
fi

nodeenv -n 8.15.1 .venv
source .venv/bin/activate
npm install -g npm
npm install -g prebuild
npm install -g node-gyp
npm install

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux";
  npm install bluetooth-hci-socket@npm:@abandonware/bluetooth-hci-socket;
fi

#!/bin/sh

if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX";
  xcode-select --install;
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux";
fi

nodeenv -n 10.15.3 .venv
source .venv/bin/activate
npm install -g npm
npm install -g prebuild
npm install -g node-gyp
npm install

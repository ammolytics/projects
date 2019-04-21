#!/bin/bash

rm -rf build .venv node_modules

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo rm /usr/bin/node /usr/bin/npm /usr/bin/npx;
fi

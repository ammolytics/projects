#!/bin/bash


if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX pre-install";
  xcode-select --install;
  nodeenv -n 8.15.1 .venv
  source .venv/bin/activate
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux pre-install";
  if ! [ -x "$(command -v node)" ]; then
    echo "Installing Node."
    wget https://nodejs.org/dist/latest-v8.x/node-v8.15.1-linux-armv7l.tar.xz;
    sudo mkdir -p /usr/local/lib/nodejs;
    sudo tar -xJvf node-v8.15.1-linux-armv7l.tar.xz -C /usr/local/lib/nodejs;
    rm node-v8.15.1-linux-armv7l.tar.xz;
    sudo ln -s /usr/local/lib/nodejs/node-v8.15.1-linux-armv7l/bin/node /usr/bin/node
    sudo ln -s /usr/local/lib/nodejs/node-v8.15.1-linux-armv7l/bin/npm /usr/bin/npm
    sudo ln -s /usr/local/lib/nodejs/node-v8.15.1-linux-armv7l/bin/npx /usr/bin/npx
  fi
fi


npm install -g prebuild
npm install -g node-gyp
npm install


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux";
  npm install --no-save bluetooth-hci-socket@npm:@abandonware/bluetooth-hci-socket;
fi

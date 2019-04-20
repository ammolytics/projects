#!/bin/bash


if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX pre-install";
  xcode-select --install;
  nodeenv -n 8.16.0 .venv
  source .venv/bin/activate
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux pre-install";
  if ! [ -x "$(command -v node)" ]; then
    echo "Installing Node."
    wget https://nodejs.org/dist/v8.16.0/node-v8.16.0-linux-armv6l.tar.xz;
    sudo mkdir -p /usr/local/lib/nodejs;
    sudo tar -xJvf node-v8.16.0-linux-armv6l.tar.xz -C /usr/local/lib/nodejs;
    rm node-v8.16.0-linux-armv6l.tar.xz;
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/node /usr/bin/node
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/npm /usr/bin/npm
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/npx /usr/bin/npx
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

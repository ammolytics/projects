#!/bin/bash

NODE_VER='8.16.0'

if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX pre-install";
  xcode-select --install;
  nodeenv -n $NODE_VER .venv;
  source .venv/bin/activate;
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux pre-install";
  if ! [ -x "$(command -v node)" ]; then
    echo "Installing Node.";
    VERS="node-v$NODE_VER-linux-$(uname -m)"
    wget https://nodejs.org/dist/v$NODE_VER/$VERS.tar.xz;
    sudo mkdir -p /usr/local/lib/nodejs;
    sudo tar -xJvf $VERS.tar.xz -C /usr/local/lib/nodejs;
    rm $VERS.tar.xz;
    sudo ln -fs /usr/local/lib/nodejs/$VERS/bin/node /usr/bin/node;
    sudo ln -fs /usr/local/lib/nodejs/$VERS/bin/npm /usr/bin/npm;
    sudo ln -fs /usr/local/lib/nodejs/$VERS/bin/npx /usr/bin/npx;
  fi
fi


sudo npm install -g npm@latest;
sudo npm install -g prebuild;
sudo npm install -g node-gyp;
npm install;


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux";
  npm install --no-save bluetooth-hci-socket@npm:@abandonware/bluetooth-hci-socket;
  sudo npm install -g pm2@latest;
  sudo ln -fs /usr/local/lib/nodejs/$VERS/lib/node_modules/pm2/bin/pm2 /usr/bin/pm2;
  sudo setcap cap_net_raw+eip $(eval readlink -f `which node`);
fi

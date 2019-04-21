#!/bin/bash


if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX pre-install";
  xcode-select --install;
  nodeenv -n 8.16.0 .venv;
  source .venv/bin/activate;
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux pre-install";
  if ! [ -x "$(command -v node)" ]; then
    echo "Installing Node.";
    wget https://nodejs.org/dist/v8.16.0/node-v8.16.0-linux-armv6l.tar.xz;
    sudo mkdir -p /usr/local/lib/nodejs;
    sudo tar -xJvf node-v8.16.0-linux-armv6l.tar.xz -C /usr/local/lib/nodejs;
    rm node-v8.16.0-linux-armv6l.tar.xz;
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/node /usr/bin/node;
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/npm /usr/bin/npm;
    sudo ln -fs /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/bin/npx /usr/bin/npx;
  fi
fi


sudo npm install -g npm@latest;
sudo npm install -g prebuild;
sudo npm install -g node-gyp;
sudo npm install -g pm2@latest ;
npm install;


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux";
  npm install --no-save bluetooth-hci-socket@npm:@abandonware/bluetooth-hci-socket;
  sudo ln -s /usr/local/lib/nodejs/node-v8.16.0-linux-armv6l/lib/node_modules/pm2/bin/pm2 /usr/bin/pm2;
  sudo setcap cap_net_raw+eip $(eval readlink -f `which node`);
fi

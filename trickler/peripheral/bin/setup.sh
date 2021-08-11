#!/bin/bash

NODE_VER='8.16.0'

if [[ "$OSTYPE" == "darwin"* ]]; then
  # OSX
  echo "OSX pre-install";
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux pre-install";
fi

python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements-to-freeze.txt


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Linux setup continued...";
fi

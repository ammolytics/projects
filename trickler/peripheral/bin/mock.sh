#!/bin/bash

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
  # Activate virtual environment when not using Linux.
  source .venv/bin/activate;
fi

MOCK=1 node index.js /dev/ttyUSB0

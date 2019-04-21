#!/bin/bash

source .venv/bin/activate

MOCK=1 node index.js /dev/ttyUSB0

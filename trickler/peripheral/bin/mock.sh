#!/bin/bash

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
  # Activate virtual environment when not using Linux.
  source .venv/bin/activate;
fi

echo "Sorry, this no longer works."

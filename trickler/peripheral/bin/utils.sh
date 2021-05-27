#!/bin/bash

# Use rsync to copy the necessary files over to the device.
upload_files() {
  echo "Syncing files to device..."
  rsync -avzC \
    --progress \
    --exclude=".git/" \
    --exclude=".venv/" \
    --delete \
    . -e ssh $USER@$HOST:projects/trickler/peripheral
  echo "Done."
}

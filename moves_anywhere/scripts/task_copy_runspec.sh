#!/bin/bash

# task_copy_runspec.sh

# Script to copy runspec from /inputs/ into EPA_MOVES_Model folder.


# Message
echo ------------copying runspec------------

# Set working direcory
cd "/cat" || { echo "Failed to change directory"; exit 1; }

# The runspec should ALWAYS be named rs_custom.xml
FOLDER_A="inputs"
FOLDER_B="EPA_MOVES_Model"
RS="rs_custom.xml"


# If the file is NOT in inputs, then STOP!
if [ ! -f "$FOLDER_A/$RS" ]; then
  echo "---$RS file not found in folder $FOLDER_A..."
  exit 1 # error
fi

# Otherwise....
# Copy from folder A to folder B
cp "$FOLDER_A/$RS" "$FOLDER_B/$RS"

# Message completion
echo "---runspec copied to folder $FOLDER_B/"

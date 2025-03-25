#!/bin/bash

# task_check_inputs.sh

# Script to quality check the inputs/ folder before proceeding with MOVES.

# Only start MOVES if required files are in place.

echo -----------checking MOVES inputs files----------------

# Set working directory
# Makes the working directory is /cat/
cd "/cat" || { echo "Failed to change directory"; exit 1; }


# Check that the folder exists.
FOLDER="inputs"

if [ ! -d "$FOLDER" ]; then
  echo "---Folder $FOLDER is missing."
  exit 1 # Exits with a non-zero status (error)
fi


# Show list of required files
FILES=(
  "$FOLDER/rs_custom.xml"
  )

# For each item in the files vector... 
for i in "${FILES[@]}"; do
  # Check if present...
  if [ ! -f "$i" ]; then
    echo "---File $i is missing."
    exit 1 # Exits with a non-zero status (error)
  fi
done

# If you make it this far, it means all required files were present.
# Print a completion message.
echo "---Folder $FOLDER contents all present."




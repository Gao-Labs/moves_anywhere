#/bin/bash

# task_copy_inputs.sh

# We're going to copy inputs from the /cat/inputs/ folder,
# into the /cat/EPA_MOVES_Model/inputs folder

# Set working directory
cd "/cat"

# Make new directory
mkdir "/cat/EPA_MOVES_Model/inputs"

# Copy all of the customized tables into new directory
cp /cat/inputs/_*.csv /cat/EPA_MOVES_Model/inputs/

# Messaging
echo "✅ Verifying key file exists:"
ls -l /cat/EPA_MOVES_Model/inputs/_sourcetypeagedistribution.csv

# Messaging
echo "-----finished copying inputs to runtime directory-------"

#!/bin/bash

#' @name demo_erin.sh
#' @author Erin
#' @description
#' A demo script for running MOVES with `moves_anywhere`
#'
#' -- Custom run
#' -- 2 custom input tables (made up)
#' -- geoid: 36109'
#' -- year: '

# Usage:
# ./demo1.sh --data_folder /path/to/data_folder --output_folder /path/to/output_folder --output_file demo1_data.rds --params_json /path/to/parameters/json/file
# Create a DATA_FOLDER/parameters.json file and configure it
# Example:
# ./demo1.sh --data_folder demo1_inputs/run1 --output_folder demos --output_file demo1_data.rds --params_json demo1_inputs/run1/parameters.json


# 0. SETUP ####################################
# Check if you have pulled tmf77/moves_anywhere:v0 already.
# If so, say yay!
# If not, pull it.

# Pull this one time
docker pull tmf77/moves_anywhere:v0


# 1. A Custom Run with 2 Tables ###########################################
# Make folder values

# Default values
DATA_FOLDER="${1:-$(pwd)/demo1_inputs/run1}" # Path to where you will source your data/inputs FROM

# Create a unique ID for your Docker container
RUN_FILE="run_id.txt"
# Check if the run file exists and is not empty
if [ -f "$RUN_FILE" ] && [ -s "$RUN_FILE" ]; then
  # Read the RUN value, increment by 1
  RUN=$(cat "$RUN_FILE")
  RUN=$((RUN+1))
else
  # Initialize RUN with 1 if file does not exist or is empty
  RUN=1
fi
# Update the run file with the new RUN value
echo $RUN > "$RUN_FILE"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --data_folder) DATA_FOLDER="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done


# Run container called 'dock', mounting the appropriate folder
# Write the file path to your inputs folder

# TESTING
docker run  \
  --name "dock$RUN" \
  --mount src="$DATA_FOLDER/",target="/cat-api/inputs",type=bind \
  -it moves_anywhere:v0 \
  bash -c "bash launch.sh;"

# Jump into the Container
docker exec -it "dock$RUN" bash

docker stop "dock$RUN"
docker rm "dock$RUN"


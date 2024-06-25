#!/bin/bash

# testme.sh
# 
# Description
#   Script to test docker container deployment.
#

# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
# Get moves_anywhere ath
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
pwd

# Variables
IMAGE_NAME="moves_anywhere:v1"
BUCKET="$(pwd)/image_moves/volume" # Path to where you will source your data/inputs FROM

# For this test, keep only parameters.json and your .csvs
# That means, cut your rs_custom.xml and any data outputs
# if [ -e "$BUCKET/rs_custom.xml" ]; then unlink "$BUCKET/rs_custom.xml"; fi



if [ -e "$BUCKET/data.rds" ]; then unlink "$BUCKET/data.rds"; fi
if [ -e "$BUCKET/data.csv" ]; then unlink "$BUCKET/data.csv"; fi
if [ -e "$BUCKET/movesoutput.csv" ]; then unlink "$BUCKET/movesoutput.csv"; fi
if [ -e "$BUCKET/movesactivityoutput.csv" ]; then unlink "$BUCKET/movesactivityoutput.csv"; fi

# If any sources are default files, delete them first
for file in "$BUCKET"/*; do
  filename=$(basename "$file")
  if [[ $filename == _* ]]; then
    unlink "$file"
  fi
done

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  -it "$IMAGE_NAME"




# # Variables
# IMAGE_NAME="moves_anywhere:v1"
# BUCKET="$(pwd)/image_moves/volume_rate" # Path to where you will source your data/inputs FROM
# 
# # For this test, keep only parameters.json and your .csvs
# # That means, cut your rs_custom.xml and any data outputs
# # if [ -e "$BUCKET/rs_custom.xml" ]; then unlink "$BUCKET/rs_custom.xml"; fi
# if [ -e "$BUCKET/data.rds" ]; then unlink "$BUCKET/data.rds"; fi
# if [ -e "$BUCKET/data.csv" ]; then unlink "$BUCKET/data.csv"; fi
# if [ -e "$BUCKET/movesoutput.csv" ]; then unlink "$BUCKET/movesoutput.csv"; fi
# if [ -e "$BUCKET/movesactivityoutput.csv" ]; then unlink "$BUCKET/movesactivityoutput.csv"; fi
# 
# # Test container - interactively (remove upon completion) #####################################
# docker run  \
#   --rm \
#   --name "dock" \
#   --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
#   -it "$IMAGE_NAME"
#   
  
  
  



# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock$RUN"
# docker rm "dock$RUN"

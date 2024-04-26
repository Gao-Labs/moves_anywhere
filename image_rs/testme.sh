#!/bin/bash

# testme.sh
# 
# Description
#   Script to test docker container deployment.
#

# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
pwd

# Variables
IMAGE_NAME="catr:v1"
DATA_FOLDER="$(pwd)/image_catr/volume" # Path to where you will source your data/inputs FROM

echo "$DATA_FOLDER"

# Delete an existing runspec if present
if [ -e "$DATA_FOLDER/rs_custom.xml" ]; then unlink "$DATA_FOLDER/rs_custom.xml"; fi


# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --mount src="$DATA_FOLDER/",target="/cat-api/inputs",type=bind \
  --name "dock" \
  -it "$IMAGE_NAME"

# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

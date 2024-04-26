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
IMAGE_NAME="upload:v1"
BUCKET="$(pwd)/image_upload/volume" # Path to where you will source your data/inputs FROM
SECRET="$(pwd)/image_upload/.Renviron"
echo "$BUCKET"

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --mount src="$SECRET/",target="/cat-api/.Renviron",type=bind \
  --name "dock" \
  -it "$IMAGE_NAME"

# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

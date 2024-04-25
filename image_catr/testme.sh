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
# DATA_FOLDER="$(pwd)/demos/demo3" # Path to where you will source your data/inputs FROM

echo "$DATA_FOLDER"

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  -it "$IMAGE_NAME"

# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

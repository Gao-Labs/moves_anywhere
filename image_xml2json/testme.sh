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
IMAGE_NAME="xml2json:v1"
DATA_FOLDER="$(pwd)/image_xml2json/inputs" # Path to where you will source your data/inputs FROM

echo "$DATA_FOLDER"

# Delete an existing translation file if present
if [ -e "$DATA_FOLDER/translation.json" ]; then unlink "$DATA_FOLDER/translation.json"; fi


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

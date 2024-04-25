#!/bin/bash
#' buildme.sh
#' 


# STARTUP ################################################################
# cd ../moves_anywhere
pwd
# Path to image folder
IMAGE_FOLDER="$(pwd)/image_catr"
# Set your DockerHub username
#DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="catr"
DOCKER_IMAGE_TAG="v1"

# PREPARE #######################################################################

# Be sure to convert launch.sh from dos format to unix format, so it will run well across platforms.
# dos2unix "$IMAGE_FOLDER/launch.sh"

# Start docker

# BUILD IMAGE #####################################################

# Set working directory
cd "$IMAGE_FOLDER"

# Build the Docker image
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . 
# --no-cache

cd ..

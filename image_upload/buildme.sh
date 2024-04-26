#!/bin/bash
#' buildme.sh
#' 


# STARTUP ################################################################
# Get moves_anywhere path
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
pwd
# Path to image folder
IMAGE_FOLDER="$(pwd)/image_upload"
# Set your DockerHub username
#DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="upload"
DOCKER_IMAGE_TAG="v1"

# PREPARE #######################################################################

# Be sure to convert launch.sh from dos format to unix format, so it will run well across platforms.
dos2unix "$IMAGE_FOLDER/launch.sh"

# Start docker

# BUILD IMAGE #####################################################

# Set working directory
cd "$IMAGE_FOLDER"

# Build the Docker image
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . 
# --no-cache

cd ..


# PRUNE ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f


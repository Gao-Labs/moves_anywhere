#!/bin/bash

# buildme.sh
# 
# Description
#   Script to build docker image from scratch.
#

# STARTUP ################################################################
# cd ../moves_anywhere
pwd
# Path to image folder
IMAGE_FOLDER="$(pwd)/image"
# Set your DockerHub username
DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="moves_anywhere"
DOCKER_IMAGE_TAG="v1"


# PREPARE #######################################################################

# Be sure to convert launch.sh from dos format to unix format, so it will run well across platforms.
dos2unix "$IMAGE_FOLDER/launch.sh"

# Start docker
start docker

# tmf77/moves_anywhere is built atop tmf77/docker_moves:v1
# Must first confirm we have this image, or get it.
IMAGE_NAME="tmf77/docker_moves:v1"
# Check if the Docker image exists locally
if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$IMAGE_NAME"; then
    IMAGE_EXISTS=true
    echo "Docker image $IMAGE_NAME has already been pulled."
else
    IMAGE_EXISTS=false
    echo "Docker image $IMAGE_NAME has not been pulled yet."
fi

# If Docker image doesn't exist locally, pull it.
if [ "$IMAGE_EXISTS" = false ]; then
  # One time, you'll need to pull this 'starter' image, which moves_anywhere is build upon
  docker pull "$IMAGE_NAME"
  echo "------------------------------------------"
  echo "Docker image $IMAGE_NAME has now been pulled."
fi


# BUILD IMAGE #####################################################

# Set working directory
cd "$IMAGE_FOLDER"

# Build the Docker image
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . --no-cache

# Reset working directory out of the image folder
cd ..

# PRUNE ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f


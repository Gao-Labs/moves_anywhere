#!/bin/bash

# uploadme.sh
# 
# Description
#   Script to upload docker image to DOCKERHUB.
#

# STARTUP ################################################################

# Path to image folder
IMAGE_FOLDER="$(pwd)/image"
# Set your DockerHub username
DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="moves_anywhere"
DOCKER_IMAGE_TAG="v1"


# UPLOAD IMAGE TO DOCKERHUB #####################################################

# Start docker
start docker

# Check that you have this image built
# Must first confirm we have this image, or get it.
IMAGE_NAME="$DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"
# Check if the Docker image exists locally
if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$IMAGE_NAME"; then
    IMAGE_EXISTS=true
    echo "Docker image $IMAGE_NAME is already present on your local computer."
else
    IMAGE_EXISTS=false
    echo "Docker image $IMAGE_NAME is not yet present/built on your local computer."
fi


# If Docker image doesn't exist locally, build it.
if [ "$IMAGE_EXISTS" = false ]; then
  
  # Set working directory
  cd "$IMAGE_FOLDER"
  # Build the Docker image
  docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . --no-cache
  # Reset working directory out of the image folder
  cd ..

  echo "------------------------------------------"
  echo "Docker image $IMAGE_NAME has now been built."
fi


# Tag the Docker image with the repository name
docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

# View your existing docker images...
docker images --format "{{.Repository}}:{{.Tag}}"

# Log in to DockerHub
docker login

# Push the Docker image to DockerHub
docker push $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

# Log out from DockerHub (optional)
docker logout


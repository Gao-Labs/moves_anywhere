#!/bin/bash

# buildme.sh
# 
# Description
#   Script to build docker image from scratch.

# buildxme.sh

# Script to build this image using Docker Build Cloud
# For developer use only.

# Login
# docker login
# Add the builder endpoint
# docker buildx create --driver cloud catcornell/timbuild

# Test build
# docker buildx build https://github.com/dockersamples/buildme.git --builder cloud-catcornell-timbuild

# Set this builder as my default builder
# docker buildx use cloud-catcornell-timbuild --global




# STARTUP ################################################################
# Get moves_anywhere path
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
pwd
# Path to image folder
IMAGE_FOLDER="$(pwd)/docker_moves"
# Set your DockerHub username
DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="moves_anywhere"
DOCKER_IMAGE_TAG="v2"


# PREPARE #######################################################################

# Be sure to convert launch.sh from dos format to unix format, so it will run well across platforms.
dos2unix setenv.sh
dos2unix setupdb.sh

# dos2unix "$IMAGE_FOLDER/launch.sh"

# Start docker
# start docker


# BUILD IMAGE #####################################################

# Set working directory
cd "$IMAGE_FOLDER"
pwd
# Build the Docker image
# docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . 
docker buildx build --builder cloud-catcornell-timbuild -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .

#--no-cache

# Reset working directory out of the image folder
cd ..

# PRUNE ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f


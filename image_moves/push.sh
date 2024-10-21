#!/bin/bash

# push.sh
 
# Script for `moves_anywhere` development team only
# Description
#    Script to push images to cloud for distributed computing.

# environmental variables #############################################

# Get moves_anywhere repository path
REPO=$(git rev-parse --show-toplevel)
REPO="C://Users/tmf77/OneDrive - Cornell University/Documents/rstudio/moves_anywhere"
cd "$REPO"

# # image_moves #################################
# echo "-----------build image_moves--------------"
# # Build image_moves/
# bash "image_moves/buildme.sh"


source 'dev/.env'
IMAGE="moves:v1"
IMAGE_NAME="$LOCATION-docker.pkg.dev/$PROJECT_NAME/$REPOSITORY/$IMAGE"
SOURCE_IMAGE="moves_anywhere:v1"

# Tag the image locally
docker tag $SOURCE_IMAGE $IMAGE_NAME
# Login with key
docker login -u _json_key --password-stdin "https://$LOCATION-docker.pkg.dev" < dev/key.json
# Push image to repository
docker push "$IMAGE_NAME"
# Logout
docker logout
# Remove the duplicate tagged image, in favor of its local name
docker image rm "$IMAGE_NAME"


# PRUNE ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f

# End script
bash



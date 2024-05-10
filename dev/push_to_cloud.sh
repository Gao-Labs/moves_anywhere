#!/bin/bash

# push_to_cloud.sh
 
# Script for `moves_anywhere` development team only
# Description
#    Script to push images to cloud for distributed computing.

# environmental variables #############################################

# Get moves_anywhere repository path
REPO=$(git rev-parse --show-toplevel)
REPO="C://Users/tmf77/OneDrive - Cornell University/Documents/rstudio/moves_anywhere"
cd "$REPO"

# Load environmental variables
# This includes: 
# REPOSITORY
# PROJECT_NAME
# LOCATION

# key #################################################
# echo "----------get key------------------------"
# Only have to do one time
# Get a key for uploading the image
# docker exec -it gcloud bash
  # gcloud auth print-access-token --impersonate-service-account "$SERVICEACCOUNT@$PROJECT_NAME.iam.gserviceaccount.com" |
  #   docker login -u oauth2accesstoken --password-stdin "https://$LOCATION-docker.pkg.dev"
# gcloud auth print-access-token

# repository ################################################
# Set up a repository on Google Artifact Registry
#
# We have an exisiting repository on Google Artifact Registry
# docker exec gcloud \
#   gcloud artifacts repositories create $REPOSITORY \
#     --repository-format=docker \
#     --location=$LOCATION

# Get moves_anywhere path
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
# image_moves #################################
echo "-----------build image_moves--------------"
# Build image_moves/
bash "image_moves/buildme.sh"

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




# image_upload ######################################
echo "-----------build image_upload--------------"
# Build image_upload/
bash "image_cloudproxy/buildme.sh"

source 'dev/.env'
IMAGE="upload:v2"
IMAGE_NAME="$LOCATION-docker.pkg.dev/$PROJECT_NAME/$REPOSITORY/$IMAGE"
SOURCE_IMAGE="upload:v2"

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

# image_rs ######################################
# echo "-----------build image_rs--------------"
# # Build image_rs/
# bash "image_rs/buildme.sh"
# 
# source 'dev/.env'
# IMAGE="rs:v1"
# IMAGE_NAME="$LOCATION-docker.pkg.dev/$PROJECT_NAME/$REPOSITORY/$IMAGE"
# SOURCE_IMAGE="rs:v1"
# 
# # Tag the image locally
# docker tag $SOURCE_IMAGE $IMAGE_NAME
# # Login with key
# docker login -u _json_key --password-stdin "https://$LOCATION-docker.pkg.dev" < dev/key.json
# # Push image to repository
# docker push "$IMAGE_NAME"
# # Logout
# docker logout
# # Remove the duplicate tagged image, in favor of its local name
# docker image rm "$IMAGE_NAME"


# PRUNE ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f

# End script
bash



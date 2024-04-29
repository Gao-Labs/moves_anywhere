#!/bin/bash

# testme.sh
# 
# Description
#   Script to test docker container deployment.
#

# Start docker before running this script
# start docker

# TEST 1: Upload using just a .Renviron (Cornell CATSERVER example) ################################################

# Working Directory should be /moves_anywhere

# Test 1

# Variables
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
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


# TEST 2: Upload using .Renviron + SSL Credentials (Cloud SQL example) #########################################

# Variables
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
IMAGE_NAME="upload:v1"
BUCKET="$(pwd)/image_upload/volume" # Path to where you will source your data/inputs FROM
SECRET="$(pwd)/image_upload/.Renvironcatcloud" # Revised values for catcloud

cd ../catrplus/movesrunner
CRED_SERVER_CA="$(pwd)/server-ca.pem"
CRED_CLIENT_CERT="$(pwd)/client-cert.pem"
CRED_CLIENT_KEY="$(pwd)/client-key.pem"
cd "$REPO"

docker run  \
  --rm \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --mount src="$SECRET/",target="/cat-api/.Renviron",type=bind \
  --mount src="$CRED_SERVER_CA/",target="/cat-api/server-ca.pem",type=bind \
  --mount src="$CRED_CLIENT_CERT/",target="/cat-api/client-cert.pem",type=bind \
  --mount src="$CRED_CLIENT_KEY/",target="/cat-api/client-key.pem",type=bind \
  --name "dock" \
  -it "$IMAGE_NAME"




# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

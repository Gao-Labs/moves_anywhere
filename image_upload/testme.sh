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
  --mount src="$SECRET/",target="/cat-api/secret1/.Renviron",type=bind \
  --mount src="$CRED_SERVER_CA/",target="/cat-api/secret2/server-ca.pem",type=bind \
  --mount src="$CRED_CLIENT_CERT/",target="/cat-api/secret3/client-cert.pem",type=bind \
  --mount src="$CRED_CLIENT_KEY/",target="/cat-api/secret4/client-key.pem",type=bind \
  --name "dock" \
  -it "$IMAGE_NAME"


# TEST 3: Upload using Cloud SQL Auth Proxy
docker run  \
  --rm \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --name "dock" \
  -it "$IMAGE_NAME"


# curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.11.0/cloud-sql-proxy.linux.386
# curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.11.0/cloud-sql-proxy.linux.386

# system("cloud_sql_proxy -instances=moves-runs:us-central1:catcloud=tcp:3306")
# system("cloud_sql_proxy --help")
# system("./cloud_sql_proxy")
# system("curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.11.0/cloud-sql-proxy.linux.386")
# system("chmod +x cloud-sql-proxy")
# system("cloud-sql-proxy --help")
# 
# # see Releases for other versions
# system('
# URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.11.0"
# 
# curl "$URL/cloud-sql-proxy.linux.amd64" -o cloud-sql-proxy
# 
# chmod +x cloud-sql-proxy
# ')
# 
# system("cloud_sql_proxy --help")
# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

#/bin/bash

# testme_cloud.sh

# Script to test MOVES Anywhere for cloud deployment

#/bin/bash
REPO="$(git rev-parse --show-toplevel)/moves_anywhere"
cd "$REPO"
pwd

# SELECT BUCKET
# BUCKET="$(pwd)/moves_anywhere"

# Variables
IMAGE_NAME="moves_anywhere:v2"
#SCRIPTS="$(pwd)/moves_anywhere/scripts"
SECRET="$(pwd)/secret"
echo $SECRET

docker run  \
--rm \
--name "dock" \
--mount src="$SECRET/",target="/cat/secret",type=bind \
--entrypoint bash \
-it "$IMAGE_NAME" 

# Check contents
ls -lh /cat/secret/


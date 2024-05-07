#!/bin/bash

# demo2/testme.sh
# 
# Description: Script to test docker container deployment AND UPLOAD TO CATSERVER
# (Only for Cornell Research Team. Other users can disregard)
# Requirements: **parameters.json**, ".Renviron", and any custom inputs. **No rs_custom.xml**
# Special Info:
# -- To upload to CATSERVER, you must fulfill all of the following conditions:
#    1. mount a .Renviron file containing the variables ORDERDATA_USERNAME, ORDERDATA_PASSWORD, ORDERDATA_HOST, and ORDERDATA_PORT.
#    2. include in parameters.json the values `dtablename` (Eg. d42091_u1_o7). This tells it where to save the file on the server.
#    3. include in parameters.json the values 'multiple' = TRUE or FALSE. This tell it whether you'll be appending multiple runs to this table, or just 1 (overwriting)

# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
pwd

# Variables
IMAGE_NAME="tmf77/moves_anywhere:v1"
DATA_FOLDER="$(pwd)/demos/demo2" # Path to where you will source your data/inputs FROM
RUN="${DATA_FOLDER##*/}" # Extract folder name. This will be the name of your docker image, eg. dockrun1 (dock$RUN)
SECRETS="$(pwd)/.Renviron" # Add path to your .Renviron file, to be mounted.
echo "$DATA_FOLDER"
echo "$RUN"
echo "$SECRETS"

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


# For this test, keep only parameters.json and your .csvs
# That means, cut your rs_custom.xml and any data outputs
if [ -e "$DATA_FOLDER/rs_custom.xml" ]; then unlink "$DATA_FOLDER/rs_custom.xml"; fi
if [ -e "$DATA_FOLDER/data.rds" ]; then unlink "$DATA_FOLDER/data.rds"; fi
if [ -e "$DATA_FOLDER/data.csv" ]; then unlink "$DATA_FOLDER/data.csv"; fi
if [ -e "$DATA_FOLDER/movesoutput.csv" ]; then unlink "$DATA_FOLDER/movesoutput.csv"; fi
if [ -e "$DATA_FOLDER/movesactivityoutput.csv" ]; then unlink "$DATA_FOLDER/movesactivityoutput.csv"; fi

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock$RUN" \
  --mount src="$DATA_FOLDER/",target="/cat-api/inputs",type=bind \
  --mount src="$SECRETS",target="/cat-api/.Renviron",type=bind \
  -it "$IMAGE_NAME" \
  bash -c "bash launch.sh;"

# Exit upon successful completion
exit

# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock$RUN"
# docker rm "dock$RUN"

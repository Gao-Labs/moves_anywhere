#!/bin/bash

# demo4/testme.sh
# 
# Description: Script to test docker container deployment SIMULTANEOUSLY
# Use Case:
#   RUNNING MULTIPLE CONTAINERS SIMULTANEOUSLY
#   AND UPLOAD RESULTS TO CATSERVER
#
# (Only for Cornell Research Team. Other users can disregard)
# Requirements: **parameters.json**, ".Renviron", and any custom inputs. **No rs_custom.xml**
# Special Info:
# -- To upload to CATSERVER, you must fulfill all of the following conditions:
#    1. mount a .Renviron file containing the variables ORDERDATA_USERNAME, ORDERDATA_PASSWORD, ORDERDATA_HOST, and ORDERDATA_PORT.
#    2. include in parameters.json the values `dtablename` (Eg. d42091_u1_o8). This tells it where to save the file on the server.
#    3. include in parameters.json the values 'multiple' = TRUE. This tell it that you'll be appending multiple runs to this table, so it doesn't overwrite the table each time.

# SETUP ###########################################################################
# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
pwd

# Variables
IMAGE_NAME="tmf77/moves_anywhere:v1"
SECRETS="$(pwd)/.Renviron" # Add path to your .Renviron file, to be mounted.
DATA_FOLDER="$(pwd)/demos/demo4" # Path to where you will source MULTIPLE FOLDERS WORTH OF DATA
mapfile -t RUN < <(basename -a "${DATA_FOLDER}"/*/) # collect a vector of folder names. Each  will be the name of your docker container, eg. dockrun1 (dock$RUN)

echo "$DATA_FOLDER"
echo "${RUN[0]}" # print the first



# PREP IMAGE ################################################################
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


# ITERATE #####################################################################

# Iterate over each element in the array
for FOLDER in "${RUN[@]}"; do
    # Testing Value
    # FOLDER=${RUN[1]}
    echo "----Element: $FOLDER"
        
    # For this test, keep only parameters.json and your .csvs
    # That means, cut your rs_custom.xml and any data outputs
    if [ -e "$DATA_FOLDER/$FOLDER/rs_custom.xml" ]; then unlink "$DATA_FOLDER/$FOLDER/rs_custom.xml"; fi
    if [ -e "$DATA_FOLDER/$FOLDER/data.rds" ]; then unlink "$DATA_FOLDER/$FOLDER/data.rds"; fi
    if [ -e "$DATA_FOLDER/$FOLDER/data.csv" ]; then unlink "$DATA_FOLDER/$FOLDER/data.csv"; fi
    if [ -e "$DATA_FOLDER/$FOLDER/movesoutput.csv" ]; then unlink "$DATA_FOLDER/$FOLDER/movesoutput.csv"; fi
    if [ -e "$DATA_FOLDER/$FOLDER/movesactivityoutput.csv" ]; then unlink "$DATA_FOLDER/$FOLDER/movesactivityoutput.csv"; fi

    # Test container - (detached, remove upon completion) #####################################
    docker run  \
      -d --rm \
      --name "dock$FOLDER" \
      --mount src="$DATA_FOLDER/$FOLDER/",target="/cat-api/inputs",type=bind \
      --mount src="$SECRETS",target="/cat-api/.Renviron",type=bind \
      -it "$IMAGE_NAME" \
      bash -c "bash launch.sh;"

done

# Array of Docker container names to monitor
echo "dock${RUN[@]}"

# Check status repeatedly with this
docker ps --filter "name=dock" --format "{{.Status}}"

# Need to stop all containers?
for DOCK in "${RUN[@]}"; do
  docker stop "dock$DOCK"
  docker rm "dock$DOCK"
done


# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock$RUN"
# docker rm "dock$RUN"

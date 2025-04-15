#/bin/bash

# dev.sh

# Development Workspace for pulling docker_moves:v2

REPO=$(git rev-parse --show-toplevel)
cd "$REPO"

# Variables
IMAGE_NAME="tmf77/docker_moves:v2"
SCRIPTS="$(pwd)/moves_anywhere/scripts"
# BUCKET="$(pwd)/moves_anywhere/inputs_ny"
BUCKET="$(pwd)/moves_anywhere/inputs2"

# [x] monthvmtfraction works
# [x] dayvmtfraction works
# [ ] hourvmtfraction works

# docker pull tmf77/docker_moves:v2

# Process for use in linux
dos2unix "$SCRIPTS/launch.sh"
dos2unix "$SCRIPTS/task_check_inputs.sh"
dos2unix "$SCRIPTS/task_start_mysql.sh"
dos2unix "$SCRIPTS/task_launch_moves.sh"
dos2unix "$SCRIPTS/task_copy_logs.sh"
dos2unix "$SCRIPTS/task_copy_runspec.sh"
dos2unix "$SCRIPTS/task_adapt.sh"
dos2unix "$SCRIPTS/task_importer.sh"
dos2unix "$SCRIPTS/launch_runspec.sh"


# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"



# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME"





# Development Workspace for moves_anywhere:v2

REPO=$(git rev-parse --show-toplevel)
cd "$REPO"

# Variables
IMAGE_NAME="moves_anywhere:v2"
SCRIPTS="$(pwd)/moves_anywhere/scripts"
# BUCKET="$(pwd)/moves_anywhere/inputs_ny"
BUCKET="$(pwd)/moves_anywhere/inputs2"

# Process for use in linux
dos2unix "$SCRIPTS/launch.sh"
dos2unix "$SCRIPTS/task_check_inputs.sh"
dos2unix "$SCRIPTS/task_start_mysql.sh"
dos2unix "$SCRIPTS/task_launch_moves.sh"
dos2unix "$SCRIPTS/task_copy_logs.sh"
dos2unix "$SCRIPTS/task_copy_runspec.sh"
dos2unix "$SCRIPTS/task_adapt.sh"
dos2unix "$SCRIPTS/task_importer.sh"
dos2unix "$SCRIPTS/launch_runspec.sh"


# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  -e YEAR=2022 \
  -e GEOID=36085 \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch_runspec.sh"


# Test container for launch command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"
docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"


  
library(DBI)
library(dbplyr)
library(dplyr)
library(RMariaDB)

db = catr::connect("mariadb", "movesdb20241112")
dbListConnection(db)
dbListObjects(db)

db %>% tbl(in_schema("movesdb20241112", "fueltype"))
dbDisconnect(db)
q()
# . scripts/launch.sh
# Check contents
# ls -lh ./scripts

# docker rm "dock" -f



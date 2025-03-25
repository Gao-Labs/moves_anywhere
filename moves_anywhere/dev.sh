#/bin/bash

# dev.sh

# Development Workspace for moves_anywhere:v2

REPO=$(git rev-parse --show-toplevel)
cd "$REPO"

# Variables
IMAGE_NAME="tmf77/docker_moves:v2"
SCRIPTS="$(pwd)/moves_anywhere/scripts"
BUCKET="$(pwd)/moves_anywhere/inputs_ny"

# Process for use in linux
dos2unix "$SCRIPTS/launch.sh"
dos2unix "$SCRIPTS/task_check_inputs.sh"
dos2unix "$SCRIPTS/task_start_mysql.sh"
dos2unix "$SCRIPTS/task_launch_moves.sh"
dos2unix "$SCRIPTS/task_copy_logs.sh"
dos2unix "$SCRIPTS/task_copy_runspec.sh"
dos2unix "$SCRIPTS/task_adapt.sh"
dos2unix "$SCRIPTS/task_importer.sh"


# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"

# . scripts/launch.sh
# Check contents
# ls -lh ./scripts

# docker rm "dock" -f



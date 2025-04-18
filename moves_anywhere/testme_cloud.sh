#/bin/bash

# testme_cloud.sh

# Script to test MOVES Anywhere for cloud deployment

#/bin/bash
# REPO="/c/Users/tmf77/OneDrive - Cornell University/Documents/rstudio/moves_anywhere/moves_anywhere"
REPO="$(git rev-parse --show-toplevel)/moves_anywhere" && cd "$REPO"

# SELECT BUCKET
BUCKET="$(pwd)/inputs2"

# Variables
IMAGE_NAME="moves_anywhere:v2"
SCRIPTS="$(pwd)/scripts"
SECRET="$(pwd)/secret"
echo $SECRET
echo $BUCKET


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
dos2unix "$SCRIPTS/launch_fuse.sh"
dos2unix "$SCRIPTS/task_fuse.sh"

# Process all files for use in linux
find "$SCRIPTS" -maxdepth 1 -name "*.sh" -print0 | while IFS= read -r -d '' file; do
  dos2unix "$file"
done


docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME"
  

# Check contents
# ls -lh /cat/secret/


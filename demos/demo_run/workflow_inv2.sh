# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
pwd

# Variables
IMAGE_NAME="moves_anywhere:v1"
DATA_FOLDER="$(pwd)/demos/demo_run/volume_inv" # Path to where you will source your data/inputs FROM
RUN="${DATA_FOLDER##*/}" # Extract folder name. This will be the name of your docker image, eg. dockrun1 (dock$RUN)

echo "$DATA_FOLDER"
echo "$RUN"

# For this test, keep only parameters.json and your .csvs
# That means, cut your rs_custom.xml and any data outputs
if [ -e "$DATA_FOLDER/data.csv" ]; then unlink "$DATA_FOLDER/data.csv"; fi
if [ -e "$DATA_FOLDER/movesoutput.csv" ]; then unlink "$DATA_FOLDER/movesoutput.csv"; fi
if [ -e "$DATA_FOLDER/movesactivityoutput.csv" ]; then unlink "$DATA_FOLDER/movesactivityoutput.csv"; fi

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock$RUN" \
  --mount src="$DATA_FOLDER/",target="/cat-api/inputs",type=bind \
  -it "$IMAGE_NAME" \
  bash -c "bash launch.sh;"

# Exit upon successful completion
exit


REPO=$(git rev-parse --show-toplevel)
cd "$REPO"

# Variables
IMAGE_NAME="moves_anywhere:v1"
BUCKET="$(pwd)/image_moves/volume_1990" # Path to where you will source your data/inputs FROM

# For this test, keep only parameters.json and your .csvs
# That means, cut your rs_custom.xml and any data outputs
# if [ -e "$BUCKET/rs_custom.xml" ]; then unlink "$BUCKET/rs_custom.xml"; fi
if [ -e "$BUCKET/data.rds" ]; then unlink "$BUCKET/data.rds"; fi
if [ -e "$BUCKET/data.csv" ]; then unlink "$BUCKET/data.csv"; fi
if [ -e "$BUCKET/movesoutput.csv" ]; then unlink "$BUCKET/movesoutput.csv"; fi
if [ -e "$BUCKET/movesactivityoutput.csv" ]; then unlink "$BUCKET/movesactivityoutput.csv"; fi

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --memory="4g" \
  --cpus="1" \
  -it "$IMAGE_NAME"




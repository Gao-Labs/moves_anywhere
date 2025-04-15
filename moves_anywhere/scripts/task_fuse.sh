#/bin/bash

# task_fuse.sh

# Script for mounting bucket with GCSFUSE
# Only applicable when run on Google Cloud

# Status update
echo '-------------MOUNTING BUCKET--------------'

# Set path to gcsfuse key, with Storage Object User permissions
KEY_FILE="/cat/secret/moves-fuse.json"
# Exit if KEY_FILE not available
[ -f "$KEY_FILE" ] || { echo "Error: File '$KEY_FILE' not found."; exit 1; }
# Login to gcloud as service account
gcloud auth activate-service-account --key-file=$KEY_FILE

# Set project ID
PROJECT_ID="moves-runs"
gcloud config set project $PROJECT_ID


# Get environmental variable from container
# BUCKET="d36123-u23-o4"
# Exit if BUCKET environmental variable not set
if [ -z "$BUCKET" ]; then
  echo "Error: BUCKET environment variable is not set."
  exit 1
fi

# Set and create mount point
MOUNT_POINT="/cat/inputs"
mkdir $MOUNT_POINT

# Mount bucket to mount point
gcsfuse --implicit-dirs $BUCKET $MOUNT_POINT

echo '-------------MOUNTED BUCKET--------------'
# If you make it this far, end script and return
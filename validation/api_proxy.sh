#/bin/bash

# Variables
FOLDER="$(git rev-parse --show-toplevel)/validation"
cd "$FOLDER"

SECRET="$(pwd)/secret"

# Load in the API_URL as an environmental variable
source secret/.env

# Test Using the Cloud Run Proxy
SERVICE="api-analyzer"
SERVICE_URL=$API_URL
PROJECT="moves-runs"
LOCATION="us-central1"
PORT=5345

# install gcloud first

# Start up the cloud run proxy in the terminal
gcloud run services proxy $SERVICE \
  --project=$PROJECT \
  --region=$LOCATION \
  --port=$PORT

# Now switch to your preferred console, eg. testing_local.R



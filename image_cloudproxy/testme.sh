#!/bin/bash

# testme.sh
# 
# Description
#   Script to test docker container deployment.
#

# Start docker before running this script
# start docker

# TEST 1: Upload using just a .Renviron (Cornell CATSERVER example) ################################################

# Working Directory should be /moves_anywhere


# TEST 2: Upload using .Renviron + SSL Credentials (Cloud SQL example) #########################################

# Variables
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
IMAGE_NAME="upload:v2"
BUCKET="$(pwd)/image_cloudproxy/volume" # Path to where you will source your data/inputs FROM
SECRET="$(pwd)/image_cloudproxy/secret"
cd "$REPO"
echo "$CRED"

# Load variables by env
source "$REPO/image_cloudproxy/.env"


docker run  \
  --rm \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --mount src="$SECRET/",target="/cat-api/secret",type=bind \
  -e "USERNAME=$USERNAME" \
  -e "PASSWORD=$PASSWORD" \
  -e "DBNAME=$DBNAME" \
  -e "INSTANCE=$INSTANCE" \
  -e "HOST=$HOST" \
  -e "PORT=$PORT" \
  --name "dock" \
  -it "$IMAGE_NAME"
  

# 
# docker run  \
#   --rm \
#   --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
#   --mount src="$CRED/",target="/cat-api/apikey.json",type=bind \
#   --env-file "$ENVFILE" \
#   --name "dock" \
#   -it "$IMAGE_NAME" \
#   bash -c "bash;"
# 
# 
# # Write a function to establish the proxy
# db_proxy() {
#   echo "Starting daemon..."
#   ./cloud-sql-proxy \
#      --credentials-file "$KEY" \
#      --address "$HOST" \
#      --port $PORT \
#      --run-connection-test \
#      "$INSTANCE"
# }
# db_proxy
# 
# #:instanceid=tcp:3306
# 
# stop_daemon() {
#     echo "Stopping daemon..."
#     # Kill the daemon process
#     kill $(pgrep -f "db_proxy.sh")
#     echo "Daemon stopped."
# }
# 
# trap 'stop_daemon' SIGTERM
# 
# db_proxy &

# mysql -u userapi -p -h 127.0.0.1
# https://cloud.google.com/sql/docs/mysql/connect-auth-proxy#expandable-1
# R
# library(DBI)
# library(RMySQL)
# library(dplyr)
# conn = DBI::dbConnect(
#   drv = RMySQL::MySQL(),
#   username = "userapi",
#   password = "moose on the keyboard",
#   host = "127.0.0.1",
#   port = as.integer("3306"),
#   dbname = "orderdata",
# )
# conn %>% dbListTables()
# dbDisconnect(conn)
# q("no")


# system("cloud_sql_proxy --help")
# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock"
# docker rm "dock"

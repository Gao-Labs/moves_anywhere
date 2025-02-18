#!/bin/bash

# testme.sh
# 
# Description
#   Script to test docker container deployment.
#

# Start docker before running this script
# start docker

# Working Directory should be /moves_anywhere
# Get moves_anywhere ath
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
pwd

# Variables
IMAGE_NAME="moves_anywhere:v1"
BUCKET="$(pwd)/image_moves/test" # Path to where you will source your data/inputs FROM

# For this test, keep only parameters.json and your .csvs
# That means, cut your rs_custom.xml and any data outputs
# if [ -e "$BUCKET/rs_custom.xml" ]; then unlink "$BUCKET/rs_custom.xml"; fi



if [ -e "$BUCKET/data.rds" ]; then unlink "$BUCKET/data.rds"; fi
if [ -e "$BUCKET/data.csv" ]; then unlink "$BUCKET/data.csv"; fi
if [ -e "$BUCKET/movesoutput.csv" ]; then unlink "$BUCKET/movesoutput.csv"; fi
if [ -e "$BUCKET/movesactivityoutput.csv" ]; then unlink "$BUCKET/movesactivityoutput.csv"; fi

# If any sources are default files, delete them first
for file in "$BUCKET"/*; do
  filename=$(basename "$file")
  if [[ $filename == _* ]]; then
    unlink "$file"
  fi
done

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
  --mount src="$REPO/image_moves/adapt.r",target="/cat-api/adapt.r",type=bind \
  --mount src="$REPO/image_moves/launch.sh",target="/cat-api/launch.sh",type=bind \
  -it "$IMAGE_NAME"

#  --entrypoint bash \

# Testing 
R

library(dplyr)
library(dbplyr)
library(DBI)
library(RMariaDB)
library(readr)
Sys.setenv("DBUSERNAME" = "moves")
Sys.setenv("DBPASSWORD" = "moves")
Sys.setenv("DBHOST" = "localhost")
Sys.setenv("DBPORT" = 3306)

conn = dbConnect(
  drv = RMariaDB::MariaDB(),
  username = Sys.getenv("DBUSERNAME"),
  password = Sys.getenv("DBPASSWORD"),
  host = Sys.getenv("DBHOST"),
  port = as.integer(Sys.getenv("DBPORT"))
)

.input = "movesdb20240104"
.output = "moves"

conn %>% 
  tbl(in_schema(.input, "sourcetypeyear")) 

conn %>% tbl(in_schema(.output, "movesoutput")) %>% 
  filter(pollutantID == 98)  %>%
  summarize(e = sum(emissionQuant, na.rm = TRUE))
  
dbDisconnect(conn)


data = read_csv("inputs/movesactivityoutput.csv")

# data %>%
#   filter(activityTypeID == 6) %>% 
#   select(sourceTypeID, regClassID, fuelTypeID, roadTypeID, activity) %>%
#   select(activity) %>%
#   distinct() %>%
#   collect() %>%
#   arrange(desc(activity)) %>%
#   print()

data %>%
  filter(activityTypeID == 6) %>% 
  select(sourceTypeID, regClassID, fuelTypeID, roadTypeID, activity) %>%
  summarize(total = sum(activity, na.rm = TRUE))

read_csv("inputs/data.csv") %>%
  filter(pollutant == 98) %>%
  filter(by == 16) %>%
  select(year, geoid, emissions, vehicles)

read_csv("inputs/data.csv") %>%
  filter(pollutant == 98) %>%
  filter(by == 16) %>%
  select(year, geoid, emissions, vehicles, vmt)

read_csv("inputs/data.csv") %>%
  filter(pollutant == 98) %>%
  filter(by == 8) %>%
  select(year, geoid, emissions, vehicles, vmt)


q()

# Not big enough.
# 1 car makes ~4 tons per year of emissions.

# # Variables
# IMAGE_NAME="moves_anywhere:v1"
# BUCKET="$(pwd)/image_moves/volume_rate" # Path to where you will source your data/inputs FROM
# 
# # For this test, keep only parameters.json and your .csvs
# # That means, cut your rs_custom.xml and any data outputs
# # if [ -e "$BUCKET/rs_custom.xml" ]; then unlink "$BUCKET/rs_custom.xml"; fi
# if [ -e "$BUCKET/data.rds" ]; then unlink "$BUCKET/data.rds"; fi
# if [ -e "$BUCKET/data.csv" ]; then unlink "$BUCKET/data.csv"; fi
# if [ -e "$BUCKET/movesoutput.csv" ]; then unlink "$BUCKET/movesoutput.csv"; fi
# if [ -e "$BUCKET/movesactivityoutput.csv" ]; then unlink "$BUCKET/movesactivityoutput.csv"; fi
# 
# # Test container - interactively (remove upon completion) #####################################
# docker run  \
#   --rm \
#   --name "dock" \
#   --mount src="$BUCKET/",target="/cat-api/inputs",type=bind \
#   -it "$IMAGE_NAME"
#   
  
  
  



# Jump into the Container
# docker exec -it "dock$RUN" bash
# exit
# docker stop "dock$RUN"
# docker rm "dock$RUN"

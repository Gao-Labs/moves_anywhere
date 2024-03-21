#!/bin/bash

#' @name demo1.sh
#' @author Tim Fraser
#' @description
#' A demo script for running MOVES with `moves_anywhere`
#' 
#' -- Custom run
#' -- 2 custom input tables (made up)
#' -- geoid: 36109'
#' -- year: '

# Usage:
# ./demo1.sh --data_folder /path/to/data_folder --output_folder /path/to/output_folder --output_file demo1_data.rds --params_json /path/to/parameters/json/file
# Create a DATA_FOLDER/parameters.json file and configure it
# Example:
# ./demo1.sh --data_folder demo1_inputs/run1 --output_folder demos --output_file demo1_data.rds --params_json demo1_inputs/run1/parameters.json

# 1. A Custom Run with 2 Tables ###########################################
# Make folder values

# Default values
DATA_FOLDER="$(pwd)/demo1_inputs/run1" # Path to where you will source your data/inputs FROM
OUTPUT_FOLDER="$(pwd)/demos" # Path to where you want to put your outputs
OUTPUT_FILE="demo1_data.rds" # Path to output file
PARAMS_JSON="${DATA_FOLDER}/parameters.json"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --data_folder) DATA_FOLDER="$2"; shift ;;
        --output_folder) OUTPUT_FOLDER="$2"; shift ;;
        --output_file) OUTPUT_FILE="$2"; shift ;;
        --params_json) PARAMS_JSON="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

main_folder=$(pwd)
data_folder=$DATA_FOLDER
output_folder=$OUTPUT_FOLDER
output_file=$OUTPUT_FILE

# Make your new json variables in your DATA_FOLDER/parameters.json
# --Change 'year' and 'geoid' and 'level' if you need
# --Change 'by' only if you know how.
# --Don't change pollutants.
# --You should update 'changes' with the names of any files you're going to enter
params_json=$PARAMS_JSON

# Path to image folder
image_folder="$(pwd)/image"
# Name to give your container
mycontainer="dock"


# Test your variables with 'echo'
echo "----------My Folder Paths--------------------"
echo "main folder:  $main_folder"
echo "image folder:  $image_folder"
echo "data folder:  $data_folder"
echo "output folder:  $output_folder"
echo "my container:  $mycontainer"
echo "params_json: " $params_json

# 3. Build Image ############################################

# Start docker
start docker

# Set working directory
cd "$image_folder";
$image_folder
# Pull 1 time
docker pull tmf77/moves_anywhere:v0

# One time, you'll need to pull this 'starter' image
# docker pull -t tmf77/docker_moves
# Build image
# docker build -t moves_anywhere:v0 . --no-cache;
# docker build -t moves_anywhere:v0 .;

# # Arguments from command line, if running it that way
# args <- commandArgs(trailingOnly = TRUE)
# if (length(args) > 0) {
#   first_arg <- args[1]
#   # You can now use first_arg as needed within your R script
# } else {
#   target_folder <- "/cat-api/inputs"
#   # Proceed with a default value if no arguments are provided
# }

# Run container called 'dock', mounting the appropriate folder
# Write the file path to your inputs folder
docker run  --name dock  \
  --mount src="$data_folder",target=target_folder, type=bind \
  -it moves_anywhere:v0

# docker rm dock

# Run script in terminal - runs preprocessing and MOVES. 
# Takes ~1.5 minutes for 1 custom county level run.
bash launch.sh

# Post-Process and Format your outputs into CAT format ###############

# Start MySQL (just in case)
service mysql start

# Rscript postprocess.r

# start R
# cp data.rds /cat-api/inputs/data.rds
R -e "data = readr::read_rds('data.rds'); readr::write_csv(data, 'inputs/data.csv')"

exit
docker rm dock

readr::read_rds("data.rds")
# Check your files
dir()
# View your output
readr::read_rds("data.rds")

# View and explore the data
library(dplyr)
library(readr)
readr::read_rds("data.rds") %>% glimpse() 
readr::read_rds("data.rds") %>% filter(by == 16) %>% glimpse() 
read_rds("data.rds") %>% write_csv("data.csv")
# Check our folder files
dir()
# Close R
q("no")
# Exit container (try it twice if it doesn't work the first time)
exit

# 4. Retrieve output files ##############################################
# Restart same container (if you exited too early.)
docker start dock
# Mark working directory
cd "$main_folder"

# Copy the csv file from docker container to your output folder & file path.
docker cp dock:cat-api/data.rds "$output_folder/$output_file"
# docker cp dock:cat-api/data.rds "$output_folder/demo1_data.rds"
docker cp dock:cat-api/data.csv "$output_folder/demo1_data.csv"

# Close Down your container
docker stop dock




# 5. (Optional) Explore Data Manually in MariaDB #######################

# Start the container back up....
docker start dock
# To enter container...
docker exec -it dock bash
# Start MySQL (just in case)
service mysql start
# start R
R
# Load packages
library(dplyr)
library(DBI)
library(RMariaDB)
library(readr)
library(catr)
# Connect to output database
con = catr::connect(type = "mariadb", "moves")
# Check status of run
con %>% tbl("movesrun") %>% glimpse()

# View results
con %>% tbl("movesoutput") %>% glimpse()

# View results
con %>% tbl("movesactivityoutput") %>% glimpse()

# Write results to file
con %>% 
  tbl("movesoutput") %>% 
  collect() %>%
  write_csv("movesoutput.csv")
con %>% 
  tbl("movesactivityoutput") %>% 
  collect() %>% 
  write_csv("movesactivityoutput.csv")
# Check our files
dir()
# Always disconnect
dbDisconnect(con)
# Quit R
q("no")
# To exit the container
exit
# Retrieve output files ##############################################
# Restart same container (if you exited too early.)
docker start dock
# Mark working directory
cd "$main_folder"

# Copy the csv file from docker container to your output folder & file path.
docker cp dock:cat-api/movesoutput.csv "$output_folder/demo1_movesoutput.csv"
docker cp dock:cat-api/movesactivityoutput.csv "$output_folder/demo1_movesactivityoutput.csv"

# Close Down your container
docker stop dock

# 6. (Optional) If you need to enter the container again #####################
# To start container...
# docker start dock
# To enter container...
# docker exec -it dock bash
# To exit...
# exit
# To stop your container...
# docker stop dock

# Delete your container (caution! You'll lose any data left inside!)
# docker rm dock

# 7. Prune any dangling images ####################################
# Always a good idea at the end. Doesn't prune any **named** images like 'moves_anywhere'
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");

docker image prune -f


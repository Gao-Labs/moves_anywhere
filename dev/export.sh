#' @name export.sh
#' @author Tim Fraser
#' @description 
#' `sh` script for exporting files from the docker container back to your local machine
#' 

# set working directory to THIS FOLDER
cd "docker_moves_v2";
# Build image
docker build -t movesimage:tim . ;
# Run container called 'dock'
docker run --name dock -it movesimage:tim;

# A SIMPLE TEXT FILE ############################

# Inside the container, let's make a file
echo "test" > test.txt
# Test print it to working directory (cat-api/)
cat test.txt

# A DATABASE TABLE AS CSV #########################

# Start MySQL Server
service mysql start

# Let's also save a MySQL Table as a .csv
# Load r
R 
# Load packages
library(dplyr)
library(readr)
library(DBI)
library(RMariaDB)
# Load connection script
source("connect.r")
# Connect to database
db = connect(type = "mariadb", "movesdb20240104")
# Query and collect a table
data = db %>% tbl("year") %>% collect()
# Write that table to file
data %>% write_csv("data.csv")
# Check file
read_csv("data.csv") %>% head()
# Disconnect from database
dbDisconnect(db)
# Clean up
rm(list = ls())
# Close out of R
q("no")

# Show other files in the current directory
ls -lh .

# Exit the container
exit

# Restate directory
cd "docker_moves_v2";

# Copy the text file from docker container to directory
docker cp dock:cat-api/test.txt test.txt
# Copy the csv file from docker container to directory
docker cp dock:cat-api/data.csv data.csv

# Using R, let's test it 
R 
# Read in the data we copied
readr::read_csv("data.csv") %>% head()
# Close out of R
q("no")

# Delete it
unlink test.txt
unlink data.csv

# Stop the docker container
docker stop dock;
# Restart the docker container
docker start dock;
# Reenter docker container
docker exec -it dock bash
# Exit docker container
exit
# Stop the docker container
docker stop dock
# Remove the docker container
docker rm dock


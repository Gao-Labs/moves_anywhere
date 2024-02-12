#' @name debugging.sh
#' @author Tim Fraser
#' @description 
#' Script for debugging MOVES runs

# start docker

# set working directory to THIS FOLDER
cd "C:/Users/tmf77/OneDrive - Cornell University/Documents/rstudio/docker_moves/docker_moves_v2";

# Start docker from command line
start docker
# List dangling images
docker images -q -f "dangling=true";
# Prune dangling images
docker rmi $(docker images -q -f "dangling=true");
# Pull docker image to your computer 1 time
# docker pull tmf77/docker_moves:v1

# Need to convert line endings from DOS to UNIX format for any files made on Windows
# dos2unix setupdb.sh;
# dos2unix launch.sh;

# Build image (needs .dockerignore file to run this from RStudio)
docker build -t movesimage:tim . ;

# Run container, named 'dock'
docker run --name dock -it movesimage:tim;

# Run launch.sh in your container
bash launch.sh

# Launch R 
# service mysql start
# R
# source("preprocess.r")


exit

# Launch R
R
# Before/After, check status:
library(dplyr)
library(DBI)
library(RMariaDB)
library(catr)
source("connect.r")
# Connect to input database
custom = connect("mariadb", "movesdb20240104")

#dbGetQuery(custom, "SELECT * FROM information_schema.TABLES LIMIT 3;")
# dbDisconnect(custom)

# For completeness, we're going to avoid the overwrite option

# Connect to output database
con = connect("mariadb", "moves")
# Check status of run
con %>% tbl("movesrun") %>% glimpse()

# View results
con %>% tbl("movesoutput") %>% glimpse()

# View results
con %>% tbl("movesactivityoutput") %>% glimpse()

# Always disconnect
dbDisconnect(con)

# Clear environemnt
rm(list = ls())

# Quit R
q("no")

# To exit the container...
exit;
exit;
# opens it in git bash
docker stop dock;
# Restarts container
docker start dock
# Enter container
docker exec -it dock bash
# Removes container
# docker rm dock;


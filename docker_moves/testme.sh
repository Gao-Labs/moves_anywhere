#/bin/bash
# testme.sh
# 
# Description
#   Script to test docker container deployment.

# Working Directory should be /moves_anywhere
# Get moves_anywhere ath
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
pwd

# Variables
IMAGE_NAME="moves_anywhere:v2"
#BUCKET="$(pwd)/image_moves2/test" # Path to where you will source your data/inputs FROM

# Test container - interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  -it "$IMAGE_NAME"


# Test out R packages
# Start R
R

getRversion()

p = as.data.frame(installed.packages())

# Which of these packages do we have?

needed = c("lubridate", "dplyr", "readr", 
  "purrr",  "tidyr", "stringr", 
  "DBI", "dbplyr", "RMariaDB", "RMySQL",
  "googleCloudStorageR",
  "remotes",
  "googleAuthR",
  "gargle",
  "httr",
  "jsonlite",
  "xml2"
  )

# Are there any packages that are needed but are not installed?
needed[!needed %in% p$Package]

# RMySQL, "googleCloudStorageR", "googleAuthR", "gargle", "httr"
# library(dplyr)
# install.packages("RMySQL")
# install.packages("cpp11")
# install.packages("RMariaDB")

# 
q(save = "no")

# Log out
exit

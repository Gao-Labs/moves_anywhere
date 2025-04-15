#/bin/bash

# testme.sh

# A script for testing moves_anywhere,
# involving making new runspecs

# Issues
# [x] custom_rs() must make outputtimefactors be Years
# [x] translate_rs() check_time must work
# [x] scaleinputdatabase and inputdatabase must be differentiated
# [x] must use MOVES 5.0 runspec as a template
# [ ] update the make_data.R script for MOVES 5.0 - pollutant processes
# [ ] confirm it works with no inputs
#    [x] need fuelsupply data for appropriate region
#    [x] fix adapt for fuelsupply - marketShare syntax
#    [x] must provide roadtypedistribution
#    [ ] get fuelformulation for fuelsubtypes 10, 20, 30, 50, 90
#    [ ] handle the NAs in fuelsubtypes 90
# [x] confirm it works with inputs

# [x] Run the NY example - inputs3
# [ ] Run NY without fuelformulation - inputs4



# Launch R
R

# working directory should be moves_anywhere/moves_anywhere
path = "C:/Users/tmf77/OneDrive - Cornell University/Documents/rstudio/moves_anywhere/moves_anywhere"
# Set working directory
setwd(path)
# Install catr
# install.packages("scripts/catr_0.2.0.tar.gz", type = "source")

library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
library(readr, warn.conflicts = FALSE, quietly = TRUE)
library(catr, warn.conflicts = FALSE, quietly = TRUE)

# Randomly select 1 county from each state.
places = read_rds("scripts/geoids.rds")  %>%
  group_by(state) %>%
  sample_n(size = 1)


for(i in 1:nrow(places)){
  
  folder = paste0("inputs_", places$geoid[i])
  dir.create(folder)
  path_rs = paste0(folder, "/rs_custom.xml")
  
  myyear = round(runif(n = 1, 2010, 2060), 0)
  
  # myyear = 2011
  # places = list(geoid = "01091")
  # i = 1
  # path_rs = "inputs_01091/rs_custom.xml"
  # library(catr)
  catr::custom_rs(
    .geoid = places$geoid[i],
    .year = myyear,
    .default = FALSE,
    .path = path_rs,
    .rate = FALSE,
    .pollutants = c(98, 3, 2, 31, 33, 110, 100, 106, 107, 116, 117), # exclude VOC
    .geoaggregation = "county",
    .timeaggregation = "year",
    .normalize = FALSE, 
    .outputdbname = "moves",
    .outputservername = "localhost",
    .inputdbname = "custom",
    .inputservername = "localhost",
    .defaultinputdbname =  "movesdb20241112",
    .defaultinputservername = "localhost",
    .skipvalidation = TRUE
  )

}

# Check runspec traits
#catr::translate_rs(path_rs)

# Close R
q(save = "no")


# Return to bash shell
#/bin/bash
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"


# Succeeeds: 06113, 09015, 10001, 11001, 25001, 33009, 34041

# Fails: 01091, 02068, 04007, 05009, 08027, 12123, 13035, 15001, 16067, 17013, 18075, 19081, 20161, 21209, 22095, 23007, 24037, 26113, 27041, 28085, 29137, 30027, 31087, 32007

# Succeeded on MOVES standard: 01091


# SELECT BUCKET
BUCKET="$(pwd)/moves_anywhere/inputs_ny"

# Variables
IMAGE_NAME="tmf77/docker_moves:v2"
SCRIPTS="$(pwd)/moves_anywhere/scripts"

docker run  \
--rm \
--name "dock" \
--mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
--mount src="$BUCKET/",target="/cat/inputs",type=bind \
--entrypoint bash \
-it "$IMAGE_NAME" 

R

# Process for use in linux
# dos2unix "$SCRIPTS/launch.sh"
# dos2unix "$SCRIPTS/task_check_inputs.sh"
# dos2unix "$SCRIPTS/task_start_mysql.sh"
# dos2unix "$SCRIPTS/task_launch_moves.sh"
# dos2unix "$SCRIPTS/task_copy_logs.sh"
# dos2unix "$SCRIPTS/task_copy_runspec.sh"
# dos2unix "$SCRIPTS/task_adapt.sh"
# dos2unix "$SCRIPTS/task_importer.sh"


# Test container - interactively (remove upon completion) #####################################
docker run  \
--rm \
--name "dock" \
--mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
--mount src="$BUCKET/",target="/cat/inputs",type=bind \
--entrypoint bash \
-it "$IMAGE_NAME" \
-c "./scripts/launch.sh"

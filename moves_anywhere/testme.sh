#/bin/bash

# dev.sh

# Development Workspace for pulling docker_moves:v2

REPO=$(git rev-parse --show-toplevel) && \
  cd "$REPO" && \
  IMAGE_NAME="tmf77/moves-anywhere:v2" && \
  SCRIPTS="$(pwd)/moves_anywhere/scripts" && \
  BUCKET="$(pwd)/moves_anywhere/inputs3"
  
  
  docker run  \
    --rm \
    --name "dock" \
    --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
    --mount src="$BUCKET/",target="/cat/inputs",type=bind \
    --entrypoint bash \
    -it "$IMAGE_NAME" \
    -c "./scripts/launch.sh"

# [x] monthvmtfraction works
# [x] dayvmtfraction works
# [ ] hourvmtfraction works

# docker pull tmf77/docker_moves:v2

# Process for use in linux
dos2unix "$SCRIPTS/launch.sh"
dos2unix "$SCRIPTS/task_check_inputs.sh"
dos2unix "$SCRIPTS/task_start_mysql.sh"
dos2unix "$SCRIPTS/task_launch_moves.sh"
dos2unix "$SCRIPTS/task_copy_logs.sh"
dos2unix "$SCRIPTS/task_copy_runspec.sh"
dos2unix "$SCRIPTS/task_adapt.sh"
dos2unix "$SCRIPTS/task_importer.sh"
dos2unix "$SCRIPTS/launch_runspec.sh"


# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"



# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME"





# Development Workspace for moves_anywhere:v2

REPO=$(git rev-parse --show-toplevel)
cd "$REPO"

# Variables
IMAGE_NAME="moves_anywhere:v2"
SCRIPTS="$(pwd)/moves_anywhere/scripts"
# BUCKET="$(pwd)/moves_anywhere/inputs_ny"
BUCKET="$(pwd)/moves_anywhere/inputs2"

# Process for use in linux
dos2unix "$SCRIPTS/launch.sh"
dos2unix "$SCRIPTS/task_check_inputs.sh"
dos2unix "$SCRIPTS/task_start_mysql.sh"
dos2unix "$SCRIPTS/task_launch_moves.sh"
dos2unix "$SCRIPTS/task_copy_logs.sh"
dos2unix "$SCRIPTS/task_copy_runspec.sh"
dos2unix "$SCRIPTS/task_adapt.sh"
dos2unix "$SCRIPTS/task_importer.sh"
dos2unix "$SCRIPTS/launch_runspec.sh"


# Test container for runspec command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  -e YEAR=2022 \
  -e GEOID=36085 \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch_runspec.sh"


# Test container for launch command interactively (remove upon completion) #####################################
docker run  \
  --rm \
  --name "dock" \
  --mount src="$SCRIPTS/",target="/cat/scripts",type=bind \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"
docker run  \
  --rm \
  --name "dock" \
  --mount src="$BUCKET/",target="/cat/inputs",type=bind \
  --entrypoint bash \
  -it "$IMAGE_NAME" \
  -c "./scripts/launch.sh"


  
library(DBI)
library(dbplyr)
library(dplyr)
library(RMariaDB)

db = catr::connect("mariadb", "movesdb20241112")
dbListConnection(db)
dbListObjects(db)

db %>% tbl(in_schema("movesdb20241112", "fueltype"))
dbDisconnect(db)
q()
# . scripts/launch.sh
# Check contents
# ls -lh ./scripts

# docker rm "dock" -f



#/bin/bash

# testme.sh

# A script for testing moves_anywhere,
# involving making new runspecs


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

#!/bin/bash
#' A demo script for running MOVES with `moves_anywhere`
#' 
#' -- Custom run
#' -- 2 custom input tables (made up)
#' -- geoid: 36109'
#' -- year: '

# 1. A Custom Run with 2 Tables ###########################################
# Make folder values
# Path to the main folder
main_folder=$(pwd)
# Path to image folder
image_folder="$(dirname $(pwd))"
image_folder="$image_folder/image"
# Path to where you WILL store your inputs
inputs_folder="$(pwd)/inputs"
# Path to where you will source your data/inputs FROM --- UPDATE THIS
data_folder="$(pwd)/demo1_inputs"
# Path to where you want to put your outputs
output_folder="$(pwd)"
# Path to output file
output_file="demo1_data.rds"
# Name to give your container
mycontainer="dock"
# Make your new json variables
# --Cange 'year' and 'geoid' and 'level' if you need
# --Change 'by' only if you know how.
# --Don't change pollutants.
# --You should update 'changes' with the names of any files you're going to enter
json_data='{
  "level" : "county",
  "geoid" :  "36109",
  "year" : 2020,
  "default" : false,
  "by" :  [ 1, 16, 8, 12, 14, 15 ],
  "pollutant" : [ 98,  91,  1, 5, 90, 31, 3, 6, 2, 87, 79, 110, 117, 116, 112, 115, 118, 119, 100, 106, 107 ],
  "changes" : [ "sourcetypeyear.csv", "startsperdaypervehicle.csv" ]
}'


# Test your variables with 'echo'
echo "----------My Folder Paths--------------------"
echo "main folder:  $main_folder"
echo "image folder:  $image_folder"
echo "inputs folder:  $inputs_folder"
echo "data folder:  $data_folder"
echo "output folder:  $output_folder"
echo "my container:  $mycontainer"
echo "json_data: " $json_data

# 2. Gather Parameters & Files as Inputs #############################

# Set working directory to main folder
cd "$main_folder"
pwd

# If there exists an inputs folder in the current directory, get rid of it.
if [ -d "$inputs_folder" ]; then
  rm -r "$inputs_folder"
fi

# Make a new folder called inputs
mkdir "$inputs_folder"

# Write the parameters to file
echo "$json_data" > "$inputs_folder/parameters.json"

# Print your parameters, just to check
cat "$inputs_folder/parameters.json"

## copy your folder of supplied csv files

# Either individually...
# cp "demos/data/sourcetypeyear.csv" "inputs/sourcetypeyear.csv"
# cp "demos/data/startsperdaypervehicle.csv" "inputs/startsperdaypervehicle.csv"
# Or all in a group at once from a folder like demos/data/
cp -r "$data_folder/"/* "$inputs_folder"


# 3. Build Image ############################################

# Set working directory
cd "$image_folder";

# One time, you'll need to pull this 'starter' image
docker pull -t tmf77/docker_moves
# Build image
docker build -t moves_anywhere:v0 . --no-cache;
# docker build -t moves_anywhere:v0 .;

# Run container called 'dock', mounting the appropriate folder
# Write the file path to your inputs folder
docker run  --name dock  \
  --mount src="$inputs_folder",target="/cat-api/inputs",type=bind \
  -it moves_anywhere:v0

# 4. Retrieve output files ##############################################
echo "----------Retrieving output files--------------------"
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

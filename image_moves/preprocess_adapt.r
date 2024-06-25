#!/usr/bin/Rscript
# Author: Tim Fraser & Colleagues

# For testing only:

## COPY RUNSPEC TO MOVES FOLDER ####################################

# Message
cat("\n---------locating runspec----------\n")

has_json = file.exists("inputs/parameters.json")
# find any runspec xml files in your directory
any_xml = dir("inputs", pattern = ".xml")
# Check if there is exactly 1 .xml document in the folder
has_xml = length(any_xml) == 1

if(has_json == TRUE & has_xml == FALSE){  
  # Now rename that runspec to a standardized name, 
  # located in the folder we'll run MOVES in
  # file.rename(from = runspec, to = "inputs/rs_custom.xml")
  # Overwrite the runspec name
  runspec = "EPA_MOVES_Model/rs_custom.xml"
  # Copy to the EPA_MOVES_Model directory
  file.copy(from = "inputs/rs_custom.xml", to = runspec, overwrite = TRUE)
  # If there IS an .xml, whether or not there is a .json
}else if(has_xml == TRUE){
  
  # Overwrite the runspec name
  runspec = "EPA_MOVES_Model/rs_custom.xml"
  # Copy that file to the EPA_MOVES_Model directory
  file.copy(from = paste0("inputs/", any_xml), to = runspec, overwrite = TRUE)
}

# 5. ADAPT INPUT DATABASE ###########################################

# Message
cat("\n---------adapting defaults into custom input database----------\n")

# Grab csv files
csvs = dir("inputs", pattern = ".csv")
# Remove any of the output csvs, so we just have input csvs
csvs = csvs[!csvs %in% c("data.csv", "movesoutput.csv", "movesactivityoutput.csv")]
# If there are any custom input tables supplied, add their file paths to the p object  
if(length(csvs) > 0){ changes = paste0("inputs/", csvs) }else{ changes = NULL }


# Adapt your default database to be a custom database,
# using a vector of supplied .csv paths, named after the tables they replace.
# Load packages
library(catr, warn.conflicts = FALSE,  quietly = TRUE)
library(DBI, warn.conflicts = FALSE, quietly = TRUE)
library(RMariaDB, warn.conflicts = FALSE,  quietly = TRUE)
library(dplyr, warn.conflicts = FALSE, quietly = TRUE)

# Load adapt() function (now in catr)
source("adapt.r")
# Run adapt() function on runspec with vector of custom input csv table paths
adapt(.changes = changes, .runspec = runspec, .save = TRUE, .volume = "inputs")
# Remove adapt function
# remove(adapt)

## diagnostics ####################

# # You could connect to the custom db - if successful, it will be **FULL.**
# source("connect.r")
# db = connect("mariadb", "movesdb20240104)
# db %>% dbListTables()
# dbDisconnect(db); remove(db)

# Closing Message
cat("\n--------preprocessing complete---------\n")

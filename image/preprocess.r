#!/usr/bin/Rscript
# Author: Tim Fraser & Colleagues

# For testing only:
# setwd("docker_moves_v2")

# 1. LOAD PACKAGES #######################################################

# Load these packages
library("catr", quietly = TRUE, warn.conflicts = FALSE)
library("dplyr", quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)
library(DBI, quietly = TRUE, warn.conflicts = FALSE)
library(RMariaDB, quietly = TRUE, warn.conflicts = FALSE)
library(RMySQL, quietly = TRUE, warn.conflicts = FALSE)
library(jsonlite, quietly = TRUE, warn.conflicts = FALSE)
library(xml2, quietly = TRUE, warn.conflicts = FALSE)

# Note that I have saved some relevant catr data dictionaries in the /context folder
# catr::by %>% readr::write_csv("context/by.csv")
# catr::tables %>% readr::write_csv("context/tables.csv")
# catr::pollutant %>% readr::write_csv("context/pollutant.csv")
# catr::fieldtypes %>% as.list()  %>% jsonlite::write_json(path = "context/fieldtypes.json")


# 2. IMPORT PARAMETERS #####################################
# Import the parameters json file as 'p'
cat("\n---------importing parameters----------")

# Be sure to go into parameters.json and update the following:

# "MDB_DEFAULT": "movesdb20240104" --> your MOVES default input database (if more recent)
# "MOVES_FOLDER": "C:/Users/Public/EPA/MOVES/MOVES4.0/" --> your MOVES folder (if more recent)
# "TEMP_FOLDER": "." --> currently write directly to your main directory

# See also "/context" folder
# Note that I have saved some relevant catr data dictionaries in the /context folder
# including for pollutants, by aggregation types, and fieldtypes

p = jsonlite::fromJSON("inputs/parameters.json")
# If there are any custom input table supplied, add the "inputs/" folder as prefix
if(!is.null(p$changes) & length(p$changes) > 0){ p$changes = paste0("inputs/", p$changes) }


# 3. SET ENV VARIABLES ########################################

# Manually set Enivironmental Variables using parameters file
# (None of these are sensitive)

# Read the .env file
source("setenv.r")

# Check that we have environmental variables
cat("\n---------checking environmental variables----------")
cat(paste0("\n-----INPUTDBNAME=", Sys.getenv("INPUTDBNAME")))
cat(paste0("\n-----OUTPUTDBNAME=", Sys.getenv("OUTPUTDBNAME")))
cat(paste0("\n-----MDB_USERNAME=", Sys.getenv("MDB_USERNAME")))
cat(paste0("\n-----MDB_PASSWORD=*********")) #,Sys.getenv("MDB_PASSWORD"))
cat(paste0("\n-----MDB_PORT=", Sys.getenv("MDB_PORT")))
cat(paste0("\n-----MDB_HOST=", Sys.getenv("MDB_HOST")))
cat(paste0("\n-----MDB_NAME=", Sys.getenv("MDB_NAME")))
cat(paste0("\n-----MDB_DEFAULT=", Sys.getenv("MDB_DEFAULT")))
cat(paste0("\n-----MOVES_FOLDER=", Sys.getenv("MOVES_FOLDER")))
cat(paste0("\n-----TEMP_FOLDER=", Sys.getenv("TEMP_FOLDER")))

## diagnostics ###########################

# Check that we can actually connect to the outputdb?
# Load connect function
# library(catr)
# # Connect to MariaDB, no database in particular.
# db = connect("mariadb")
# # Print all databases available to you
# db %>% dbGetQuery("SHOW DATABASES;")
# Should include both outputdb "moves" and inputdb "movesdb20240104"
# # Disconnect
# dbDisconnect(db); remove(db)

# Output database has already been initialized by the setupdb.sh script
# in the original docker image docker_moves:v1,
# which we build docker_moves:v2 on.

# 4. MAKE CUSTOM RUNSPEC #########################################

cat("\n---------making custom runspec----------")
# Make a custom runspec, which includes the inputs you provided!
p$runspec = catr::custom_rs(
  .outputdbname = Sys.getenv("OUTPUTDBNAME"), .inputdbname = Sys.getenv("INPUTDBNAME"),
  .level = p$level, .geoid = p$geoid, .year = p$year, 
  .default = p$default, 
  # Save in the inputs folder (? - optional)
  .dir = "inputs")

# Now copy that runspec to a standardized name, 
# located in the folder we'll run MOVES in
file.copy(from = p$runspec, to = "EPA_MOVES_Model/rs_custom.xml", overwrite = TRUE)
# Overwrite the runspec name
p$runspec = "EPA_MOVES_Model/rs_custom.xml"

# custom_rs sets the default pollutants run to be this whole list.
# That's good! We want that.
# catr::pollutant$id

## diagnostics ########################

# View your runspec xml doc
# p$runspec %>% xml2::read_xml()


# 5. ADAPT INPUT DATABASE ###########################################

# Message
cat("\n---------adapting defaults into custom input database----------")


# Adapt your default database to be a custom database,
# using a vector of supplied .csv paths, named after the tables they replace.
# Load packages
library(catr, quietly = TRUE)
library(DBI, quietly = TRUE)
library(RMariaDB, quietly = TRUE)
library(dplyr, quietly = TRUE)

# Load adapt() function (now in catr)
# source("adapt.r")
# Run adapt() function on runspec with vector of custom input csv table paths
adapt(.changes = p$changes, .runspec = p$runspec)
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

#' @name preprocess_rs.R
#' @description
#' Shortened version of the preprocess script.
#' Does the following
#' Checks if your bucket has a parameters.json but NOT an xml
#' If so, makes a runspec from it. 
#' If your bucket has an xml, makes a parameters.json from it.

# 1. LOAD PACKAGES #######################################################

# Load these packages
library("catr", quietly = TRUE, warn.conflicts = FALSE)
library("dplyr", quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)
library(DBI, quietly = TRUE, warn.conflicts = FALSE)
library(RMySQL, quietly = TRUE, warn.conflicts = FALSE)
library(jsonlite, quietly = TRUE, warn.conflicts = FALSE)
library(xml2, quietly = TRUE, warn.conflicts = FALSE)

# Note that I have saved some relevant catr data dictionaries in the /context folder
# catr::by %>% readr::write_csv("context/by.csv")
# catr::tables %>% readr::write_csv("context/tables.csv")
# catr::pollutant %>% readr::write_csv("context/pollutant.csv")
# catr::fieldtypes %>% as.list()  %>% jsonlite::write_json(path = "context/fieldtypes.json")


# 1. SET ENV VARIABLES ########################################

# Manually set Enivironmental Variables using parameters file
# (None of these are sensitive)

# Read the .env file
source("setenv.r")

# Check that we have environmental variables
cat("\n---------checking environmental variables----------\n")
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


# 2. IMPORT PARAMETERS #####################################
# Import the parameters json file as 'p'
cat("\n---------importing parameters----------\n")

# Check if your folder contains a parameters.json file or .xml runspec.
# If it contains a .json file, PREFER that.
# If it contains a .xml runspec, use that.
has_json = file.exists("inputs/parameters.json")
# find any runspec xml files in your directory
any_xml = dir("inputs", pattern = ".xml")
# Check if there is exactly 1 .xml document in the folder
has_xml = length(any_xml) == 1
# Grab csv files
csvs = dir("inputs", pattern = ".csv")
# Remove any of the output csvs, so we just have input csvs
csvs = csvs[!csvs %in% c("data.csv", "movesoutput.csv", "movesactivityoutput.csv")]
# If there are any custom input tables supplied, add their file paths to the p object  
if(length(csvs) > 0){ changes = paste0("inputs/", csvs) }else{ changes = NULL }


# 4. MAKE CUSTOM RUNSPEC #########################################


# custom_rs sets the default pollutants run to be this whole list.
# That's good! We want that.
# catr::pollutant$id

# If there IS a .json but NOT an .xml
if(has_json == TRUE & has_xml == FALSE){
  
  p = jsonlite::fromJSON("inputs/parameters.json")
  # If there are any custom input table supplied, add the "inputs/" folder as prefix
  # if(!is.null(p$changes) & length(p$changes) > 0){ p$changes = paste0("inputs/", p$changes) }
  
  cat("\n---------making custom runspec----------\n")
  # Make a custom runspec, which includes the inputs you provided!
  runspec = catr::custom_rs(
    .outputdbname = Sys.getenv("OUTPUTDBNAME"), .inputdbname = Sys.getenv("INPUTDBNAME"),
    .level = p$level, .geoid = p$geoid, .year = p$year, .default = p$default, 
    # Save in the inputs folder (? - optional)
    .path = "inputs/rs_custom.xml")

  # If there IS an .xml, whether or not there is a .json
}else if(has_xml == TRUE){
  
  cat("\n---------using existing runspec----------\n")
  
  runspec = paste0("inputs/", any_xml[1])
  
  p = translate_rs(.runspec = runspec)
  # Extract relevant fields
  p = p %>% with(list(level = level, geoid = geoid, year = year, default = default, pollutant = pollutant))
  # Assume these by fields by default
  p$by = c(1, 16, 8, 12, 14, 15)
  
  # Write this list to file as a JSON
  p %>%
    jsonlite::toJSON(., pretty = TRUE) %>%
    # Write parameters
    cat(file = "inputs/parameters.json", sep = "\n")
  
}else{ stop("Neither a .json nor .xml provided. Stopping run...")  }



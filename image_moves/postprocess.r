#!/usr/bin/Rscript

#' @name postprocess.r
#' @title postprocessing code for formatting run AFTER invoking MOVES
#' @author Tim Fraser & colleagues

library(dplyr)
library(readr)
library(catr)

# Load environmental variables
source("setenv.r")

# Does your directory contain a parameters file?
has_json = file.exists("inputs/parameters.json")

# If json is present, create inputs/data.csv
if(has_json == TRUE){
  # Post process the data
  path = postprocess_format(
    path_data = "data.rds", csv = FALSE, 
    by = c(1, 16, 15, 14, 12, 8), pollutant = NULL, 
    path_parameters = "inputs/parameters.json")
  
  print(path)
  
  # Check it
  path %>% readr::read_rds() %>% head()
  
  # Write it to file as .csv in the mounted inputs/ folder.
  read_rds("data.rds") %>% write_csv("inputs/data.csv")
  
}

# Either way, extract this data.
# Grab movesoutput and movesactivityoutput as .csvs in the mounted inputs/ folder
library(DBI)
library(dplyr)
library(catr)
library(readr)
db = catr::connect(type = "mariadb", "moves")
db %>% tbl("movesoutput") %>% collect() %>% write_csv("inputs/movesoutput.csv")
db %>% tbl("movesactivityoutput") %>% collect() %>% write_csv("inputs/movesactivityoutput.csv")
DBI::dbDisconnect(db)


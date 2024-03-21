#!/usr/bin/Rscript

#' @name postprocess.r
#' @title postprocessing code for formatting run AFTER invoking MOVES
#' @author Tim Fraser & colleagues

library(dplyr)
library(readr)
library(catr)

# Load environmental variables
source("setenv.r")
# Post process the data
path = postprocess_format(
  path_data = "data.rds", csv = FALSE, 
  by = c(1, 16, 15, 14, 12, 8), pollutant = NULL, 
  path_parameters = "inputs/parameters.json")

print(path)

# Check it
path %>% readr::read_rds() %>% head()
read_rds("data.rds") %>% write_csv("inputs/data.csv")

# Grab movesoutput and movesactivityoutput
library(DBI)
library(dplyr)
library(catr)
library(readr)
db = catr::connect(type = "mariadb", "moves")
db %>% tbl("movesoutput") %>% collect() %>% write_csv("inputs/movesoutput.csv")
db %>% tbl("movesactivityoutput") %>% collect() %>% write_csv("inputs/movesactivityoutput.csv")
DBI::dbDisconnect(db)


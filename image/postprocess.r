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
read_rds("data.rds") %>% write_csv("data.csv")
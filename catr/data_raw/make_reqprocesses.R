#' @name make_reqprocesses.R
#' @description
#' Script to generate the `reqprocesses` dataset, 
#' to be included and used in `catr` for generating runspecs in `custom_rs`
#' Depends on `R/get_polprocesses.R` script
#' 

# Set working directory
setwd(rstudioapi::getActiveProject())
setwd("catr")

# Load polprocesses functions
source("R/get_polprocesses.R")

reqprocesses = catr::tab_pollutant %>%
  select(pollutantID) %>%
  # Ignore pollutants not present in the MOVES cheatsheet
  filter(
    # These are represented in the Cheatsheet
    pollutantID %in% c(1:185),
    # Except for these ids, which are not present
    !pollutantID %in% c(83, 99, 120, 3000)) %>%
  # For each pollutantID
  group_by(pollutantID) %>%
  # Give me back all pollutant-process IDs.
  reframe(polProcessID = get_polprocesses(.pollutantID = pollutantID))
# Save to file
save(reqprocesses, file = "data/reqprocesses.rda")
# Clear
rm(list = ls())

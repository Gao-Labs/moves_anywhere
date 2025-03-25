#/bin/bash

# task_get_defaults.sh

# Script to get several key default input tables from MOVES
R
# Load packages
library(dplyr)
library(readr)
library(dbplyr)
library(DBI)
library(RMariaDB)
library(catr)

# folder = "scripts/defaults"

get_table = function(table, folder = "scripts/defaults", defaultdb = "movesdb20241112"){ 
  # Make a folder of defaults
  dir.create(folder, showWarnings = FALSE)
  # Connect to database
  db = catr::connect("mariadb", defaultdb)
  # Collect table
  data = db %>% tbl(table) %>% collect()
  # Disconnect
  dbDisconnect(db)
  # Write to file
  write_csv(data, file = paste0(folder, "/", table, ".csv"))
  # Status message
  cat(paste0("\n---downloaded: ", table, "----------------", "\n"))
}


get_table(table = "fuelsupply")
get_table(table = "fuelformulation")
get_table(table = "fuelusagefraction")

# Close out of R
q(save = "no")

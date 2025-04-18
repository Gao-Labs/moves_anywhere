# task_create_importer_fuse.R

# Script to create an importer.xml file

# R # start R, if needed
# Load packages
library(catr, warn.conflicts = FALSE,  quietly = TRUE)
library(DBI, warn.conflicts = FALSE, quietly = TRUE)
library(RMariaDB, warn.conflicts = FALSE,  quietly = TRUE)
library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
library(dbplyr, warn.conflicts = FALSE, quietly = TRUE)

# Set directory
setwd("/cat/")
# Load the importer
source("scripts/importer.R")

# Create importer, for SPECIAL use in Google Cloud Run 
# when manually mounting bucket with gcsfuse in task_fuse.sh
path_importer = create_importer(
  BUCKET = "inputs", 
  SOURCE = "scripts", 
  dir = "/cat/EPA_MOVES_Model")

cat("\n---created importer.xml file...\n")

# Close R
q(save = "no")

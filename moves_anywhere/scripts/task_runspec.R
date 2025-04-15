# task_runspec.R

# Task script to create a runspec .xml file

# Loda packages
setwd("/cat")
library(catr, warn.conflicts = FALSE, quietly = TRUE)

GEOID = Sys.getenv("GEOID")
YEAR = as.integer(Sys.getenv("YEAR"))

if(nchar(GEOID) == 0){ stop("GEOID is required environmental variable. Stopping...") }
if(nchar(YEAR) == 0){ stop("YEAR is required environmental variable. Stopping...") }

# Make the runspec
catr::custom_rs(
  .geoid = GEOID, .year = YEAR, .pollutants = c(98, 3, 2, 31, 33, 110, 100, 106, 107, 116, 117),
  .rate = FALSE, .level = "county", .geoaggregation = "county", .timeaggregation = "year",
  .path = "inputs/rs_custom.xml"
)

# Close R
q(save = "no")

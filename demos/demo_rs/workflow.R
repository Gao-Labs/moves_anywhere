#' @name workflow.R
#' @author Tim Fraser
#' @description
#' Workflow that demos the creation of custom runspec.xml documents

# Packages
library(dplyr)
library(xml2)
library(catr)

# Set active project
setwd(rstudioapi::getActiveProject())
setwd("demos/demo_rs")

getwd()

# Write a basic runspec, with minimal conditions

# A custom county-level Inventory mode run in 36109 in 2020
custom_rs(.geoid = "36109", .year = 2020, .default = FALSE, .rate = FALSE, .path = "rs1.xml")

# A rate mode county-level run, where results are aggregated by link and hour
custom_rs(.geoid = "36109", .year = 2020, .default = FALSE, .rate = TRUE, .path = "rs2.xml",
          .level = 'county', .geoaggregation = "link",  .timeaggregation = 'hour')

# A rate mode county-level run, where results are aggregated by county and year,
# just for C02e (98) and Methane (6)
custom_rs(.geoid = "36109", .year = 2020, .default = FALSE, .rate = TRUE, .path = "rs3.xml",
          .pollutants = c(98, 6), 
          .level = 'county', .geoaggregation = "county",  .timeaggregation = 'year')

# An inventory mode state-level run, aggregated to the state level
custom_rs(.geoid = "36", .year = 2020, .default = FALSE, .rate = TRUE, .path = "rs4.xml",
          .level = 'state', .geoaggregation = "state",  .timeaggregation = 'year')

# An inventory mode county-level run, 
# for just passenger vehicles (21) 
# that are electric (9) 
# on urban unrestricted roads (5)
# By default, level is interpreted from geoid, geoaggregation matches the level, and time aggregation is annual
custom_rs(.geoid = "36109", .year = 2020, .default = FALSE, .rate = TRUE, .path = "rs5.xml",
          .sourcetype = 21, .fueltypes = 9, .roadtypes = 5)


# View key metadata from runspecs
translate_rs(.runspec = "rs1.xml")
translate_rs(.runspec = "rs2.xml")
translate_rs(.runspec = "rs3.xml")
translate_rs(.runspec = "rs4.xml")
translate_rs(.runspec = "rs5.xml")

# Write a parameters.json file from a runspec's metadata
rs_to_parameters(
  path_rs = "rs3.xml", path_parameters = "parameters3.json",
  tablename = "d36109_u1_o1", by = c(1,16))

# Write a parameters.json file from a runspec's metadata
rs_to_parameters(
  path_rs = "rs5.xml", path_parameters = "parameters5.json",
  tablename = "d36109_u1_o1", by = c(1,16))


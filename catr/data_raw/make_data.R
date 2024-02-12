#' @name make_data.R
#' @author Tim Fraser
#' @title A script for making our package data.
#' @description
#' Let's make a series of objects that will help us run our functions.

# CATR ###################################################

## setup ###################################

# Prep Necessary Items
# Tim Fraser, Feb 2023
require(dplyr, warn.conflicts = FALSE)
require(tidyr, warn.conflicts = FALSE)
require(readr, warn.conflicts = FALSE)
require(stringr, warn.conflicts = FALSE)
require(purrr, warn.conflicts = FALSE)

# Set working directory to project directory
setwd(rstudioapi::getActiveProject())
# Zoom into catr directory
setwd("./catr")

## types #####################################################

# Get a list of all types
types = tidyr::expand_grid(
  level = c("nation", "state", "county", "project"),
  prefix = c("mo", "mao") ) %>%
  mutate(type = prefix %>% dplyr::recode("mo" = "emissions", "mao" = "activity")) %>%
  mutate(table = prefix %>% dplyr::recode("mo" = "movesoutput", "mao" = "movesactivityoutput")) %>%
  mutate(path = paste0("data_raw/example_", .$prefix, "_", .$level, ".csv")) %>%
  # Filter to whatever levels actually are available now
  filter(level %in% c("nation", "county", "state")) 

usethis::use_data(types, overwrite = TRUE)
#save(types, file = "data/types.rda")


## metadata #####################################################

library(dplyr)
library(readr)
library(stringr)
library(purrr)

# Get metadata-making function
source("data_raw/metadata.R")
# Get read it function
source("data_raw/read_it.R")

# For each type, generate metadata using the example files in helper
# load("data/types.rda")
# types$path

metadata = list(
  # Get county level metadata  
  county = list(
    activity = metadata(path = "data_raw/example_mao_county.csv", .level = "county"),
    emissions = metadata(path = "data_raw/example_mo_county.csv", .level = "county")
  ),
  # Get state level metadata
  state = list(
    activity = metadata(path = "data_raw/example_mao_state.csv", .level = "state"),
    emissions = metadata(path = "data_raw/example_mo_state.csv", .level = "state")
  ),
  # Get nation level metadata
  nation = list(
    activity = metadata(path = "data_raw/example_mao_nation.csv", .level = "nation"),
    emissions = metadata(path = "data_raw/example_mo_nation.csv", .level = "nation") 
  )
)

usethis::use_data(metadata, overwrite = TRUE)
#save(metadata, file = "data/metadata.rda")


# Example of how you would produce a 5-row example template from a local connection to a MariaDB nation-level database.
# Does not need to be run. Just an FYI.
#local %>% tbl("movesoutput") %>% head() %>% collect() %>% write_csv("z/example_mo_nation.csv")
#local %>% tbl("movesactivityoutput") %>% head() %>% collect() %>% write_csv("z/example_mao_nation.csv")

## by #####################################################

# Get all the by-combinations
by = tribble(
  ~id, ~term,                                      
  "1", "sourcetype, regclass, fueltype, roadtype",
  "2", "sourcetype, regclass, fueltype",
  "3", "sourcetype, regclass, roadtype",
  "4", "sourcetype, regclass",
  "5", "sourcetype, fueltype, roadtype",
  "6", "sourcetype, fueltype",
  "7", "sourcetype, roadtype",
  "8", "sourcetype",
  "9", "regclass, fueltype, roadtype",
  "10", "regclass, fueltype",
  "11", "regclass, roadtype",
  "12", "regclass",
  "13", "fueltype, roadtype",
  "14", "fueltype",
  "15", "roadtype",
  "16", "overall"
) %>%
  mutate(id = as.integer(id)) 
usethis::use_data(by, overwrite = TRUE)
#save(by, file = "data/by.rda")

## fieldtypes #####################################################

# Make MySQL field types for our CAT FORMATTED data
# Must be supplied as a named vector
fieldtypes = c(
  by = "tinyint(2)",
  year = "smallint(4)",
  geoid = "char(5)",
  pollutant = "tinyint(3)",
  sourcetype = "tinyint(2)",
  regclass = "tinyint(2)",
  fueltype = "tinyint(1)",
  roadtype = "tinyint(1)",
  emissions = "double(18,1)",
  vmt = "double(18,1)",
  sourcehours = "double(18,1)",
  vehicles = "double(18,1)",
  starts = "double(18,1)",
  idlehours = "double(18,1)",
  hoteld = "double(18,1)",
  hotelb = "double(18,1)",
  hotelo = "double(18,1)")
usethis::use_data(fieldtypes, overwrite = TRUE)
#save(fieldtypes, file = "data/fieldtypes.rda")



# Clear environment
rm(list = ls()); 



## pollutant #####################################################

# Get full labels for every type of pollutant (for kicks. Not currently used outside of dashboard.)
pollutant = tribble(
  ~id, ~term, ~label,
  "98", "CO2 Equivalent", "CO2e",
  "91", "Total Energy Consumption", "Energy Consumption",
  "1", "Total Gaseous Hydrocarbons (TGH)", "TGH",
  "5", "Methane (CH4)", "CH4",
  "90", "Atmospheric CO2", "Atmospheric CO2",
  "31", "Sulfur Dioxides (SO2)", "SO2",
  "3", "Oxides of Nitrogen (NOx)", "NOx",
  "6", "Nitrous Oxide (N20)", "N20",
  "2", "Carbon Monoxide (CO)", "CO",
  "87", "Volatile Organic Compounds", "VOC",
  "79", "Non-Methane Hydrocarbons", "NMH",
  "110", "Primary Exhaust PM2.5 - Total", "PM2.5",
  "117", "Primary PM2.5 - Tirewear Particulate", "PM2.5 - Tirewear",
  "116", "Primary PM2.5 - Brakeware Particulate", "PM2.5 - Brakewear",
  "112", "Elemental Carbon", "Elemental Carbon",
  "115", "Sulfate Particulate", "Suflate Particulate",
  "118", "Composite - NonECPM", "Composite - NonECPM",
  "119", "H20 (aerosol)", "H20",
  "100", "Primary Exhaust PM10 - Total", "PM10",
  "106", "Primary PM10 - Breakware Particulate", "PM10 - Breakware",
  "107", "Primary PM10 - Tirewear Particulate", "PM10 - Tirewear") %>%
  mutate(id = as.integer(id))
usethis::use_data(pollutant, overwrite = TRUE)
#save(pollutant, file = "data/pollutant.rda")


## rs_template #####################################################

# Save runspec template as a list, so it can be encoded within the package.
rs_template = xml2::read_xml("data_raw/rs_template.xml") %>% xml2::as_list()
usethis::use_data(rs_template, overwrite = TRUE)
#save(rs_template, file = "data/rs_template.rda")
remove(rs_template)


## demo #####################################################

# Script for making demo data for README

library(dplyr)
library(readr)
library(DBI)
library(RMariaDB)

# Connect to your default database - located on your local computer
# need MOVES installed for this
db = dbConnect(
  drv = RMariaDB::MariaDB(),
  username = 'moves',
  password = "moves",
  host = "localhost",
  port = 3306,
  # Old default database - can update - that's fine
  dbname = "movesdb20221007")

### sourcetypeyear #####################################################

# Let's make a 'fake' custom input table, using this existing table
db %>% 
  tbl("sourcetypeyear") %>%
  filter(yearID == 2020) %>%
  mutate(sourceTypePopulation = case_when(
    sourceTypeID == 11 ~ sourceTypePopulation * 0.90,
    TRUE ~ sourceTypePopulation)) %>%
  collect() %>%
  write_csv("data_raw/sourcetypeyear.csv")

### startsperdaypervehicle #####################################################

# Let's make a 'fake' custom input table, using this existing table
db %>% 
  tbl("startsperdaypervehicle") %>% 
  mutate(startsPerDayPerVehicle = case_when(
    sourceTypeID == 11 & dayID %in% c(2, 5) ~ startsPerDayPerVehicle * 0.90, 
    TRUE ~ startsPerDayPerVehicle)) %>%
  collect() %>%
  write_csv("data_raw/startsperdaypervehicle.csv")

dbDisconnect(db); remove(db)


# END #########################################

rm(list = ls()); gc()


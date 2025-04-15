#' @name queries.R
#' @author Tim Fraser
#' @title Performance Tests of MOVES Anywhere on CAT Cloud


# Test 1
# First, we want to run a series of MOVES runs for a few well-understood counties.
# We could do this using NY state data (?)

# SETUP #################################

# Set working directory
setwd(paste0(rstudioapi::getActiveProject(), "/validation"))

library(dplyr)
library(readr)
library(purrr)
library(httr)
library(readxl)
library(googleAuthR)

# Load functions
source("functions.R")
# Load environmental variables
readRenviron("secret/.env")


# We're going to run a few scenarios.

# Scenario 18: Defaults Revised ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, let's do default.

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

setwd(paste0(rstudioapi::getActiveProject(), "/validation"))
library(dplyr)
library(readr)
library(httr)
library(jsonlite)
library(purrr)

# before = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
# 
# geoids = readr::read_rds("../moves_anywhere/scripts/geoids.rds") %>%
#   filter(state == "NY") %>%
#   filter(!geoid %in% before) %>%
#   with(setNames(object = geoid, nm = stringr::str_remove(name, " County[,] NY")))

# geoids = c("36079", "36119")
# geoids = c("36061", "36085", "36097", "36103","36111", "36113", "36115", "36117", "36119", "36121", "36123")

# geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat
scenario = 18

for(i in 1:length(geoids)){
  
  geoid = geoids[i]
  
  result = app_new_order(user = auth$cat$userid, geoid = geoid, year = 2022, zipfile = NULL)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = NA) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  cat(paste0("\n---", i, " completed: ", geoid, "\n"))
}



# Scenario 19: +sourcetypeyearvmt ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 19
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  # path_avft = paste0("temp/avft.csv")
  # read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft) 
  # 
  # path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  # read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  # path_roadtypedistribution = "temp/roadtypedistribution.csv"
  # read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution) 
  
  # path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  # read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution) 
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
   
  # path_sourcetypeyear = "temp/sourcetypeyear.csv"
  # read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    #path_avft, "avft",
    #path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    # path_roadtypedistribution, "roadtypedistribution",
    # path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    # path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 20: +sourcetypeyear ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 20
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  # path_avft = paste0("temp/avft.csv")
  # read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft) 
  # 
  # path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  # read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  # path_roadtypedistribution = "temp/roadtypedistribution.csv"
  # read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution) 
  
  # path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  # read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution) 
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    #path_avft, "avft",
    #path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    # path_roadtypedistribution, "roadtypedistribution",
    # path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 21: +roadtypedistribution ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 21
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  # path_avft = paste0("temp/avft.csv")
  # read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft) 
  # 
  # path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  # read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)

  # path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  # read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution) 
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    #path_avft, "avft",
    #path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    # path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 22: +sourcetypeagedistribution ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 22
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  # path_avft = paste0("temp/avft.csv")
  # read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft) 
  # 
  # path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  # read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    #path_avft, "avft",
    #path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 23: +avgspeeddistribution ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 23
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  # path_avft = paste0("temp/avft.csv")
  # read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft) 
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    #path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 24: +avft ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 24
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  path_avft = paste0("temp/avft.csv")
  read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft)
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  # path_zonemonthhour = "temp/zonemonthhour.csv"
  # read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour) 
  
  
  paths = tribble(
    ~path, ~file,
    path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear"
    # path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 25: +zonemonthhour ############################################


# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 25
# geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
# geoids = "36047"
geoids = c("36061", "36085")
# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  path_avft = paste0("temp/avft.csv")
  read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft)
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  # path_imcoverage = "temp/imcoverage.csv"
  # read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage) 
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  path_zonemonthhour = "temp/zonemonthhour.csv"
  read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour)

  
  paths = tribble(
    ~path, ~file,
    path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    # path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear",
    path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}

# Scenario 26: +imcoverage ############################################


# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 26
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  path_avft = paste0("temp/avft.csv")
  read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft)
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  #path_fuelformulation = paste0("temp/fuelformulation.csv")
  #read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation) 
  
  #path_fuelsupply = paste0("temp/fuelsupply.csv")
  #read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply) 
  
  # path_fuelusagefraction = "temp/fuelusagefraction.csv"
  # read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction) 
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  path_imcoverage = "temp/imcoverage.csv"
  read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage)
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  path_zonemonthhour = "temp/zonemonthhour.csv"
  read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour)
  
  
  paths = tribble(
    ~path, ~file,
    path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    #path_fuelformulation, "fuelformulation",
    #path_fuelsupply, "fuelsupply",
    # path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear",
    path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}


# Scenario 28: +fuel ############################################


# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>% 
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 28
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")


# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  path_avft = paste0("temp/avft.csv")
  read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft)
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  # path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  # read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction) 
  
  path_fuelformulation = paste0("temp/fuelformulation.csv")
  read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation)
  
  path_fuelsupply = paste0("temp/fuelsupply.csv")
  read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply)
  
  path_fuelusagefraction = "temp/fuelusagefraction.csv"
  read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction)
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  path_imcoverage = "temp/imcoverage.csv"
  read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage)
  # 
  # 
  # path_monthvmtfraction = "temp/monthvmtfraction.csv"
  # read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction) 
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  path_zonemonthhour = "temp/zonemonthhour.csv"
  read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour)
  
  
  paths = tribble(
    ~path, ~file,
    path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    path_fuelformulation, "fuelformulation",
    path_fuelsupply, "fuelsupply",
    path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear",
    path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)
  
  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = zippath) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}



# Scenario 29: +vmt (day/month) ############################################

# This time, we're going to design a straightforward query.
# Show me the 5 boroughs of New York City, as default vs. as custom.
# This time, show me the custom values

# tigris::fips_codes %>%
#   filter(state == "NY") %>%
#   select(county_code, county) %>%
#   filter(str_detect(county, "New York|Bronx|Queen|King|Richmond"))

scenario = 29
#geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")

before = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
geoids = readr::read_rds("../moves_anywhere/scripts/geoids.rds") %>%
  filter(state == "NY") %>%
  filter(!geoid %in% before) %>%
  with(setNames(object = geoid, nm = stringr::str_remove(name, " County[,] NY")))

# files = dir("data", full.names = TRUE)
for(i in 1:length(geoids)){
  
  # i = 1  
  dir.create("temp")
  
  path_avft = paste0("temp/avft.csv")
  read_csv("data_ny/2022_AVFT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avft)
  # 
  path_avgspeeddistribution = paste0("temp/avgspeeddistribution.csv")
  read_csv("data_ny/2022_avgspeeddistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_avgspeeddistribution)
  # 
  path_dayvmtfraction = paste0("temp/dayvmtfraction.csv")
  read_csv("data_ny/2022_DayVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_dayvmtfraction)
  
  path_fuelformulation = paste0("temp/fuelformulation.csv")
  read_csv("data_ny/2022_FuelFormulation.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_fuelformulation)
  
  path_fuelsupply = paste0("temp/fuelsupply.csv")
  read_csv("data_ny/2022_FuelSupply.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelsupply)
  
  path_fuelusagefraction = "temp/fuelusagefraction.csv"
  read_csv("data_ny/2022_FuelUsageFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_fuelusagefraction)
  
  # path_hourvmtfraction = "temp/hourvmtfraction.csv"
  # read_csv("data_ny/2022_HourVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_hourvmtfraction) 
  # 
  path_imcoverage = "temp/imcoverage.csv"
  read_csv("data_ny/2022_IMCoverage.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_imcoverage)
  # 
  # 
  path_monthvmtfraction = "temp/monthvmtfraction.csv"
  read_csv("data_ny/2022_MonthVMTFraction.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_monthvmtfraction)
  # 
  # 
  path_roadtypedistribution = "temp/roadtypedistribution.csv"
  read_csv("data_ny/2022_RoadTypeDistribution.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_roadtypedistribution)
  
  path_sourcetypeagedistribution = "temp/sourcetypeagedistribution.csv"
  read_csv("data_ny/2022_SourceTypeAgeDistribution.csv", show_col_types = FALSE) %>% filter(FIPS == geoids[i]) %>% write_csv(path_sourcetypeagedistribution)
  
  path_sourcetypeyearvmt = "temp/sourcetypeyearvmt.csv"
  read_csv("data_ny/2022_SourceTypeYearVMT.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyearvmt)
  
  path_sourcetypeyear = "temp/sourcetypeyear.csv"
  read_csv("data_ny/2022_SourcetypeYear.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_sourcetypeyear)
  # 
  path_zonemonthhour = "temp/zonemonthhour.csv"
  read_csv("data_ny/2022_ZoneMonthHour.csv", show_col_types = FALSE) %>% filter(FIP == geoids[i]) %>% write_csv(path_zonemonthhour)
  
  
  paths = tribble(
    ~path, ~file,
    path_avft, "avft",
    path_avgspeeddistribution, "avgspeeddistribution",
    #path_dayvmtfraction, "dayvmtfraction",
    path_fuelformulation, "fuelformulation",
    path_fuelsupply, "fuelsupply",
    path_fuelusagefraction, "fuelusagefraction",
    # path_hourvmtfraction, "hourvmtfraction",
    path_imcoverage, "imcoverage",
    # path_monthvmtfraction, "monthvmtfraction",
    path_roadtypedistribution, "roadtypedistribution",
    path_sourcetypeagedistribution, "sourcetypeagedistribution",
    path_sourcetypeyearvmt, "sourcetypeyearvmt",
    path_sourcetypeyear, "sourcetypeyear",
    path_zonemonthhour, "zonemonthhour"
  )
  library(zip)
  
  # Zip files
  FOLDER = paste0("inputs", scenario)
  
  dir.create(FOLDER, showWarnings = FALSE)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zip::zip(zipfile = zippath, files = c(paths$path), mode = "cherry-pick")
  # unzip(zipfile = zippath, exdir = "test")
  
  # Delete temp folder
  unlink("temp", recursive = TRUE, force = TRUE)
  
  cat(paste0("\n---", i, " zipfile prepped: ", geoids[i], "\n"))
}

# Login
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat


for(i in 18:length(geoids)){
#for(i in 1:length(geoids)){
  FOLDER = paste0("inputs", scenario)
  zippath = paste0(FOLDER, "/", geoids[i], ".zip")
  zipfile = paste0(getwd(), "/", zippath)

  result = app_new_order(user = auth$cat$userid, geoid = geoids[i], year = 2022, zipfile = zipfile)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>%
    mutate(file = zippath) %>%
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)

  # Completion message
  cat(paste0("\n---", i, " completed: ", geoids[i], "\n"))
}



# Download Data ####################################


# # runs = read_csv("runs.csv")
# x = app_bucket_object_list(bucket = runs$bucket[length(runs$bucket)]) 
# read_csv(x, show_col_types = FALSE) 
# filter(name == "data.csv")

runs = read_csv("runs.csv") %>%
  filter(scenario %in% c(29))
# 
# geoids = c("36079", "36119")
# runs = read_csv("runs.csv") %>%
#   filter(scenario %in% c(18)) %>%
#   filter(geoid %in% geoids)

# runs = runs %>% tail(1)
# gc()
# unlink(tempdir(), recursive = TRUE, force = TRUE)
# Download Results
for(i in 1:nrow(runs)){
  app_bucket_retrieve_data(bucket = runs$bucket[i]) %>%
    write_lines(paste0("outputs/", runs$bucket[i], ".csv"))
  cat(paste0("\n---", i, " completed: ", runs$bucket[i], "\n"))
  
}


# dir.create("movesoutputs")
# # Download Results
# for(i in 1:nrow(runs)){
#   
#   x = app_bucket_retrieve_movesoutput(bucket = runs$bucket[i])
#   x = readr::read_csv(x, show_col_types = FALSE)
#   path_output = paste0("movesoutputs/", runs$bucket[i], ".csv")
#   readr::write_csv(x = x, file = path_output)
#   remove(x)
#   cat(paste0("\n---", i, " completed: ", runs$bucket[i], "\n"))
#   
# }


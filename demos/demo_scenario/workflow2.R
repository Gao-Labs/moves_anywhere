#' @name workflow2
#' @title Upgraded Workflow for Scenario Analysis (multi-year runs)
#' @author Tim


library(catr)
library(dplyr)
library(readr)
#library(translators)

# Set active project as directory
setwd(rstudioapi::getActiveProject())
setwd("demos/demo_scenario")

source("get_scenario.R")

# Testing
# catr::rs_to_parameters(path_rs = "volume/r2020/rs_custom.xml",
#                        path_parameters = "volume/r2020/parameters.json")

user = 1
geoid = "36109"
key_path = "../../runapikey.json" # path to your private runapikey.json

get_scenario(user = user, geoid = geoid, years = 1990,
             level = "county", geoaggregation = "county", timeaggregation = "year",rate = FALSE, 
             key_path = key_path)


get_scenario(user = user, geoid = geoid, years = 1990,
             level = "county", geoaggregation = "county", timeaggregation = "hour",rate = FALSE, 
             key_path = key_path)


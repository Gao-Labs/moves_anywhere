#' @name workflow_rate
#' @title Workflow for a Cloud MOVES Rate run

#' Tests a workflow 

# Get your active project from rstudioapi package
setwd(rstudioapi::getActiveProject())
setwd("demos/demo_run")

# Load package
library(dplyr)
library(catr)

source("trigger_run.R")

key_path = "../../runapikey.json"
folder = "./volume_rate"

t = trigger_run(
  geoid = "36109", year = 2020, level = "county", default = FALSE,
  geoaggregation = "county", timeaggregation = "year", rate = TRUE,
  pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107,116, 117),
  folder = folder, key_path = key_path)
t

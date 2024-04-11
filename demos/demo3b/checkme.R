#' @name checkme.R
# Post-hoc analytics to check performance.

library(dplyr)
library(readr)
library(translators)
# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
readRenviron(".Renviron")

translators::get_sourcetypeyear_cat(.year = 2025, .table = "d42091", .pollutant = 98) %>%
  mutate(sourceTypePopulation = case_when(sourceTypeID == 11 ~ sourceTypePopulation * 1.20, TRUE ~ sourceTypePopulation)) %>%
  write_csv("demos/demo3b/sourcetypeyear.csv")

# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
# Zoom into our demo of choice
setwd("demos/demo3a")

library(dplyr)
library(readr)

read_csv("data.csv") %>%
  filter(by == 8, pollutant == 98, sourcetype == 11) %>%
  select(sourcetype, emissions, vehicles)
read_csv("data.csv") %>% filter(by == 16, pollutant == 98) %>% select(emissions, vehicles)
  
read_csv("sourcetypeyear.csv") 
20888/3000
# uhh....

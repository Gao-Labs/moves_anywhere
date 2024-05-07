#' @name checkme.R
# Post-hoc analytics to check performance.

library(dplyr)
library(readr)
library(translators)
# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
readRenviron(".Renviron")

translators::get_sourcetypeyearvmt_cat(.year = 2025, .table = "d42091", .pollutant = 98) %>%
  mutate(VMT = case_when(sourceTypeID == 11 ~ VMT * 1.20, TRUE ~ VMT)) %>%
  write_csv("demos/demo5/sourcetypeyearvmt.csv")

# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
# Zoom into our demo of choice
setwd("demos/demo5")

library(dplyr)
library(readr)

read_csv("data.csv") %>%
  filter(by == 8, pollutant == 98, sourcetype == 11) %>%
  select(sourcetype, emissions, vehicles)
read_csv("data.csv") %>% filter(by == 16, pollutant == 98) %>% select(emissions, vehicles)
  
read_csv("sourcetypeyearvmt.csv") 
20888/3000
# uhh....

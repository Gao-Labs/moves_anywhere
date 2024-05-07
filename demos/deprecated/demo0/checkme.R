#' @name checkme.R
# Post-hoc analytics to check performance.
# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
# Zoom into our demo of choice
setwd("demos/demo0")

library(dplyr)
library(readr)

read_csv("data.csv") %>%
  filter(by == 8, pollutant == 98) %>%
  select(sourcetype, emissions, vehicles)

read_csv("sourcetypeyear.csv") 

# uhh....

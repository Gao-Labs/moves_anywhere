#' @name setupme.R
# Pre-run computations to generate data (for use by CAT team only)

library(dplyr)
library(readr)
library(translators)
# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
readRenviron(".Renviron")

translators::get_sourcetypeyear_cat(.year = 2025, .table = "d42091", .pollutant = 98) %>%
  mutate(sourceTypePopulation = case_when(sourceTypeID == 11 ~ sourceTypePopulation * 1.20, TRUE ~ sourceTypePopulation)) %>%
  write_csv("demos/demo6/sourcetypeyear.csv")


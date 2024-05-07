#' @name dev_demo_inputs.R
#' @author Tim Fraser
#' @description
#' This script allows for replication 
#' of the demo input csv files in `demos/demo_inputs`.
#' 
#' @note This script uses the `translators` package,
#'  a private package not currently available to the public. 
#'  This script is intended for Cornell CAT researcher use only.

# Load packages
library(dplyr)
library(readr)
library(translators)
library(rstudioapi)

# Set active project as directory
setwd(rstudioapi::getActiveProject())
# Read Renviron file
readRenviron(".Renviron") # You'll need credentials to access CATSERVER granddata.
# Only available to Cornell CAT researchers.

# Use translator functions to generate 
get_sourcetypeyear_cat(.year = 2020, .table = "d36109",.pollutant = 98) %>% 
  write_csv("demos/demo_inputs/sourcetypeyear.csv")

get_sourcetypeyearvmt_cat(.year = 2020, .table = "d36109", .pollutant = 98) %>%
  write_csv("demos/demo_inputs/sourcetypeyearvmt.csv")

get_avft_def() %>%
  write_csv("demos/demo_inputs/avft.csv")

get_hourvmtfraction_def() %>%
  write_csv("demos/demo_inputs/hourvmtfraction.csv")

get_hpmsvtypeyear_cat(.year = 2020, .table = "d36109", .pollutant = 98) %>%
  write_csv("demos/demo_inputs/hpmsvtypeyear.csv")

get_imcoverage_def(.county = "36109", .year = 2020) %>%
  write_csv("demos/demo_inputs/imcoverage.csv")

get_sourcetypeagedistribution_def(.year = 2020) %>%
  write_csv("demos/demo_inputs/sourcetypeagedistribution.csv")

get_avgspeeddistribution_def() %>%
  write_csv("demos/demo_inputs/avgspeeddistribution.csv")

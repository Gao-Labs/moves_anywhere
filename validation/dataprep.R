# dataprep.R

# Script to prepare data for later visualization in analysis.R


library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(ggplot2)
library(ggtext)
library(viridis)


setwd(paste0(rstudioapi::getActiveProject(), "/validation"))

# DATA16 ########################################################

# Data by aggregation level 16 - overall

geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
runs = read_csv("runs.csv", show_col_types = FALSE) %>% 
  filter(scenario %in% c(18,19,20,21,22,23,24,25,26,28, 29) ) %>%
  filter(stringr::str_detect(bucket, pattern = paste0(geoids, collapse = "|") )) %>%
  mutate(output = paste0("outputs/", bucket, ".csv")) %>%
  # Filter out any that were invalid
  filter(file.size(output) > 1000)


# runs %>% filter(bucket == "d36047-u23-o25")

# Read in the files
runs %>% 
  # Filter to buckets that were successfully downloaded
  filter(output %in% dir("outputs", full.names = TRUE)) %>%
  # For each bucket
  split(.$bucket) %>%
  # Read in the data
  map_dfr(
    .f = ~read_csv(.x$output, show_col_types = FALSE) %>%
      filter(by == 16) %>%
      mutate(bucket = .x$bucket, scenario = .x$scenario)
  ) %>%
  mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) %>%
  left_join(by = "geoid", y=  read_rds("../moves_anywhere/scripts/geoids.rds") %>% 
              mutate(name = stringr::str_remove(name, " County[,] NY"))) %>%
  saveRDS("data16.rds")




# DATA8 ############################################

# Data by aggregation level 8 - sourcetype

runs %>% 
  # Filter to buckets that were successfully downloaded
  filter(output %in% dir("outputs", full.names = TRUE)) %>%
  # For each bucket
  split(.$bucket) %>%
  # Read in the data
  map_dfr(
    .f = ~read_csv(.x$output, show_col_types = FALSE) %>%
      filter(pollutant == 98, by == 8) %>%
      mutate(bucket = .x$bucket, scenario = .x$scenario)
  ) %>%
  mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) %>%
  left_join(by = "geoid", y=  read_rds("../moves_anywhere/scripts/geoids.rds") %>% 
              mutate(name = stringr::str_remove(name, " County[,] NY")))  %>%
  saveRDS("data8.rds")


# DATA16-ALL #########################################

# Data by aggregation level 16 - for ALL counties in NY
runs = read_csv("runs.csv", show_col_types = FALSE) %>% 
  filter(scenario %in% c(18,26,28, 29) ) %>%
  mutate(output = paste0("outputs/", bucket, ".csv")) %>%
  # Filter out any that were invalid
  filter(file.size(output) > 1000)


# runs %>% filter(bucket == "d36047-u23-o25")

# Read in the files
runs %>% 
  # Filter to buckets that were successfully downloaded
  filter(output %in% dir("outputs", full.names = TRUE)) %>%
  # For each bucket
  split(.$bucket) %>%
  # Read in the data
  map_dfr(
    .f = ~read_csv(.x$output, show_col_types = FALSE) %>%
      filter(by == 16) %>%
      mutate(bucket = .x$bucket, scenario = .x$scenario)
  ) %>%
  mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) %>%
  left_join(by = "geoid", y=  read_rds("../moves_anywhere/scripts/geoids.rds") %>% 
              mutate(name = stringr::str_remove(name, " County[,] NY"))) %>%
  saveRDS("data16_compare.rds")


# DATA8-ALL ############################################
# Data by aggregation level 8 - by sourcetype - for ALL counties in NY

read_csv("runs.csv", show_col_types = FALSE) %>% 
  filter(scenario %in% c(18,26,28, 29) ) %>%
  mutate(output = paste0("outputs/", bucket, ".csv")) %>%
  # Filter out any that were invalid
  filter(file.size(output) > 1000) %>%
  # Filter to buckets that were successfully downloaded
  filter(output %in% dir("outputs", full.names = TRUE)) %>%
  # For each bucket
  split(.$bucket) %>%
  # Read in the data
  map_dfr(
    .f = ~read_csv(.x$output, show_col_types = FALSE) %>%
      filter(by == 8) %>%
      mutate(bucket = .x$bucket, scenario = .x$scenario)
  ) %>%
  mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) %>%
  left_join(by = "geoid", y=  read_rds("../moves_anywhere/scripts/geoids.rds") %>% 
              mutate(name = stringr::str_remove(name, " County[,] NY"))) %>%
  saveRDS("data8_compare.rds")


# DATA1-ALL ################################################

# data aggregation by aggregation level 1 - fully disaggregated - for all counties in NY
runs = read_csv("runs.csv", show_col_types = FALSE) %>% 
  filter(scenario %in% c(y, yhat) ) %>%
  mutate(output = paste0("outputs/", bucket, ".csv")) %>%
  # Filter out any that were invalid
  filter(file.size(output) > 1000)
# runs %>% filter(bucket == "d36047-u23-o25")

# Read in the files
runs %>% 
  # Filter to buckets that were successfully downloaded
  filter(output %in% dir("outputs", full.names = TRUE)) %>%
  # For each bucket
  split(.$bucket) %>%
  # Read in the data
  map_dfr(
    .f = ~read_csv(.x$output, show_col_types = FALSE) %>%
      filter(by == 1) %>%
      mutate(bucket = .x$bucket, scenario = .x$scenario)
  ) %>%
  mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) %>%
  left_join(by = "geoid", y=  read_rds("../moves_anywhere/scripts/geoids.rds") %>% 
              mutate(name = stringr::str_remove(name, " County[,] NY"))) %>%
  saveRDS("data1_compare.rds")





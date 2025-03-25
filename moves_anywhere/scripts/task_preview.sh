# task_preview.R

# Preview results using R

R
# setwd("moves_anywhere")
# setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))
library(dplyr)
library(readr)

FOLDER="inputs_ny"

path = paste0(FOLDER, "/movesoutput.csv")

data = path %>% 
  read_csv() %>%
  filter(pollutantID == 98) %>%
  select(sourceTypeID, regClassID, fuelTypeID, roadTypeID, emissionQuant)

data %>% 
  summarize(emissions = sum(emissionQuant, na.rm = TRUE)) %>%
  with(emissions)



path = paste0(FOLDER, "/movesactivityoutput.csv")

data = path %>% 
  read_csv() %>%
  filter(activityTypeID == 6)

data %>% 
  summarize(activity = sum(activity, na.rm = TRUE)) %>%
  with(activity)


# AAAAAAAAH 
# Why does it think there are only 21 cars in Tompkins County???


dir("inputs_ny")

read_csv(paste0(FOLDER, "//sourcetypeyear.csv")) %>%
  filter(FIP == 36109) %>%
  summarize(total = sum(sourceTypePopulation))


# 4 tons per car per year

# 62558 vehicles in tompkins county
# (4 * 62558)/ 365

paste0(FOLDER, "/_startsperdaypervehicle.csv") %>%
read_csv()

paste0(FOLDER, "/hourvmtfraction.csv") %>%
read_csv() %>%
  filter(FIP == 36109) 


111 * 24 * 365

111 * 365

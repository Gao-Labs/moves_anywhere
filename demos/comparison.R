#' @name checkme.R
# Post-hoc analytics to check performance.

library(dplyr)
library(readr)

# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
# Zoom into our demo of choice
setwd("demos")

# Let's compare demo7, where we made NO change to sourcetype 11 
read_csv("demo7/data.csv") %>%
  filter(by == 8, pollutant == 98, sourcetype == 11) %>%
  select(sourcetype, emissions, vehicles, starts, vmt,  sourcehours) 

# Let's compare demo 6, where we made a +20% change to sourcetype 11
read_csv("demo6/data.csv") %>%
  filter(by == 8, pollutant == 98, sourcetype == 11) %>%
  select(sourcetype, emissions, vehicles, starts, vmt,  sourcehours)

# Changing vehicles in sourcetypeyear.csv 
# changes the vehicles and starts metrics, 
# but not vmt or sourcehours metrics.


# Their emissions numbers ARE different in demo6 vs. demo7
# but that is not getting reflected in cat format....
read_csv("demo6/movesoutput.csv") %>%
  filter(sourceTypeID == 11, pollutantID == 98) %>%
  summarize(emissions = sum(emissionQuant, na.rm = TRUE)) %>%
  with(emissions)


read_csv("demo7/movesoutput.csv") %>%
  filter(sourceTypeID == 11, pollutantID == 98) %>%
  summarize(emissions = sum(emissionQuant, na.rm = TRUE)) %>%
  with(emissions)

# Emissions is not changing, but the vehicles tally is....


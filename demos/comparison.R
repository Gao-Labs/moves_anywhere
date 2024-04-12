#' @name checkme.R
# Post-hoc analytics to check performance.

library(dplyr)
library(readr)

# Set working directory to repo main directory
setwd(rstudioapi::getActiveProject())
# Zoom into our demo of choice
setwd("demos")

# data.csv ######################################
## OVERALL ###################################
test1 = function(path = "demo6/data.csv"){
  path %>%
    read_csv() %>%
    filter(by == 16, pollutant ==98)  %>%
    select(emissions, vehicles, starts, vmt, sourcehours)
}
bind_rows(
  test1(path = "demo6/data.csv"),
  test1(path = "demo7/data.csv"),
  test1(path = "demo8/data.csv")
)

## BY SOURCETYPE == 11 #######################################
# Let's compare demo7, where we made NO change to sourcetype 11 
test2 = function(path = "demo7/data.csv"){
  path %>% 
    read_csv() %>%
    filter(by == 8, pollutant == 98, sourcetype == 11) %>%
    select(sourcetype, emissions, vehicles, starts, vmt,  sourcehours) 
}

# Let's compare demo 6, where we made a +20% change to sourcetype 11
bind_rows(
  test2("demo6/data.csv"),
  test2("demo7/data.csv"),
  test2("demo8/data.csv")
)

# Changing vehicles in sourcetypeyear.csv 
# changes the vehicles and starts metrics, 
# but not vmt or sourcehours metrics.

# movesoutput.csv ##############################

## OVERALL ##############################################
# Their total emissions numbers are different in demo6 vs. demo7
test3 = function(path = "demo7/movesoutput.csv"){
  path %>%
  read_csv() %>%
  filter(pollutantID == 98) %>%
  summarize(emissions = sum(emissionQuant, na.rm = TRUE)) %>%
  select(emissions)
}
bind_rows(
  test3("demo6/movesoutput.csv"),
  test3("demo7/movesoutput.csv"),
  test3("demo8/movesoutput.csv")
)

## BY SOURCETYPE == 11 ######################################
# Their emissions numbers ARE different in demo6 vs. demo7
# but that is not getting reflected in cat format....
test4 = function(path = "demo7/movesoutput.csv"){
  path %>%
    read_csv() %>%
    filter(sourceTypeID == 11, pollutantID == 98) %>%
    summarize(emissions = sum(emissionQuant, na.rm = TRUE)) %>%
    select(emissions)
  
}
bind_rows(
  test4("demo6/movesoutput.csv"),
  test4("demo7/movesoutput.csv"),
  test4("demo8/movesoutput.csv")
)

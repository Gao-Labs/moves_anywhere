#' @name process_by2
#' @title `process_by2()`
#' @description
#' Meta-function to process emissions and activity data, by invoking the process_emissions.R and process_activity.R scripts.
#' Process data from a local set of csvs for one '.by' group, for a specified .geoid at a given .level
#' Can specify a specific .pollutant if you only want one pollutant. Otherwise, .pollutant = NULL runs all pollutants by default
#' @param path_e path to `movesoutput.csv`
#' @param path_a path to `movesactivityoutput.csv`
#' @param .by:int integer from 1-16 describing aggregation ID. 
#' @param .geoid:str eg. "36109"
#' @param .level:str "county", "state", or "nation", but usually "county"
#' @param .pollutant:int integer vector of EPA pollutant IDs
#' @export
#' @importFrom dplyr tbl `%>%` filter select left_join mutate any_of
#' @importFrom readr read_csv write_csv
#' @importFrom utils data
#' @author Tim Fraser, March 2023
process_by2 = function(path_e, path_a, geoid = "36109", .level = "county", .pollutant = NULL, .by = 1){
  
  # Identify the right geographic identifier for your level of run 
  vars_geo = switch(
    EXPR = .level,
    "county" = c(geoid = "countyID"),
    "state" = c(geoid = "stateID"),
    "nation" = c(geoid = "stateID"),
    "zone" = c(geoid = "zoneID"),
    "link" = c(geoid = "linkID")
  )
  
  # EMISSIONS ###############################
  
  # Read in emissions data
  q_e = path_e %>%
    read_csv(show_col_types = FALSE)
  
  # Grab and rename columns according to our template
  q_e = q_e %>% 
    select(c(
      year = "yearID", any_of(vars_geo), pollutant = "pollutantID",
      sourcetype = "sourceTypeID", regclass = "regClassID", 
      fueltype = "fuelTypeID", roadtype = "roadTypeID", 
      emissions = "emissionQuant")) 
  
  # Process (and collect into local memory) emissions data using the supplied settings
  emissions = process_emissions(tab = q_e, .by = .by, .pollutant = NULL, .geoid =  geoid) 
  
  # Remove emissions data
  remove(q_e)
  
  
  # ACTIVITY ###############################
  # Read in activity data
  q_a = path_a %>% read_csv(show_col_types = FALSE)
  
  q_a = q_a %>% select(
    year = "yearID", any_of(vars_geo), 
    sourcetype = "sourceTypeID", regclass = "regClassID", 
    fueltype = "fuelTypeID", roadtype = "roadTypeID",
    activitytype = "activityTypeID", activity = "activity"
  )
  
  # Process (and collect into local memory) activity data using the supplied settings
  activity = process_activity(tab = q_a, .by = .by, .geoid = geoid)
  
  # Remove activity data
  remove(q_a)
  
  
  # COMBINE ###############################
  
  # Get the column names from your emissions query results
  nm = names(emissions)
  # Identify any extra joining categories specific to your .by call (eg. sourcetype, etc.)
  cats = nm[!nm %in% c("year", "geoid", "pollutant", "emissions")]
  
  # Make .by an integer, since that's more efficient
  .by = as.integer(.by)
  
  result = emissions %>% 
    # Join activity data into the emissions data
    left_join(by = c("year", "geoid", cats), y = activity) %>%
    # Label this data output with its '.by' number
    mutate(by = .by)
  
  return(result)
  
}


#' @name get_data
#' @title Get `data.csv` from a `movesoutput` and `movesactivityoutput` pair of csvs
#' @description
get_data = function(){
  # Load packages
  library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  library(readr, warn.conflicts = FALSE, quietly = TRUE)
  library(tidyr, warn.conflicts = FALSE, quietly = TRUE)
  library(stringr, warn.conflicts = FALSE, quietly = TRUE)
  library(purrr, warn.conflicts = FALSE, quietly = TRUE)
  library(jsonlite, warn.conflicts = FALSE, quietly = TRUE)
  library(catr, warn.conflicts = FALSE, quietly = TRUE)
  
  # Set variables
  FOLDER = "inputs"
  setwd("/cat")
  
  # For testing only
  # Set working directory
  # setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))
  # FOLDER = "inputs_ny"
  
  # Set paths
  path_e = paste0(FOLDER, "/", "movesoutput.csv")
  path_a = paste0(FOLDER, "/", "movesactivityoutput.csv")
  path_json = paste0(FOLDER, "/", "parameters.json")
  path_data = paste0(FOLDER, "/", "data.csv") # path we will give to it soon
  
  # Extract metadata from runspec
  # path_rs = paste0(FOLDER, "/", "rs_custom.xml")
  # rs = catr::translate_rs(path_rs)
  # geoid = rs$geoid
  # .level = rs$level
  
  # Extract metadata from parameters file
  p = jsonlite::fromJSON(path_json)
  
  # Save to file
  purrr::map_dfr(
    .x = p$by,
    .f = ~process_by2(path_e = path_e, path_a = path_a, 
                      geoid = p$geoid, .level = p$level, .pollutant = p$pollutant, .by = .)
  ) %>%
    saveRDS("data.rds")
  
  # Write it to file as .csv in the mounted inputs/ folder.
  read_rds("data.rds") %>% write_csv(path_data)
  
}

#' @name process_by
#' @title `process_by()`
#' @description
#' Meta-function to process emissions and activity data, by invoking the process_emissions.R and process_activity.R scripts.
#' Process data from a local MariaDB connection 'con' for one '.by' group, for a specified .geoid at a given .level
#' Can specify a specific .pollutant if you only want one pollutant. Otherwise, .pollutant = NULL runs all pollutants by default
#' Can specific a specific .run if there are multiple runs in your database. Otherwise, just takes the contents of your database
#' @param con ...
#' @param .by ...
#' @param .geoid ...
#' @param .level ...
#' @param .run ...
#' @param .pollutant ...
#' @export
#' @importFrom dplyr tbl `%>%` filter select left_join mutate
#' @importFrom utils data
#' @author Tim Fraser, March 2023

process_by = function(con, .by = 16, .geoid = '36109', .level = "county", .run = NULL, .pollutant = NULL){
  #require(dplyr, warn.conflicts = FALSE)
  #require(DBI, warn.conflicts = FALSE)
  #require(RMariaDB, warn.conflicts = FALSE)
  
  # Some example settings, for testing if desired. Keep commented otherwise.
  # con = local
  # .by = 16
  # .geoid = "00"
  # .level = "nation"
  # .run = NULL
  # .pollutant = NULL
  
  # Clear cache
  gc()
  
  # PROCESS EMISSIONS DATA ###################################################
  # Load function for processing emissions data
  # source("R/process_emissions.R")
  # Get formatting metadata for an emissions dataset corresonding to your supplied .level of moves data. 

  # Identify the right geographic identifier for your level of run 
  vars_geo = switch(
    EXPR = .level,
    "county" = c(geoid = "countyID"),
    "state" = c(geoid = "stateID"),
    "nation" = c(geoid = "stateID"),
    "zone" = c(geoid = "zoneID"),
    "link" = c(geoid = "linkID")
  )
  
  # Access movesoutput table (emissions)
  q_e = con %>% tbl("movesoutput")
  # If there's a specific run, filter to that run (but it's not required)
  if(!is.null(.run)){ q_e = q_e %>% filter(MOVESRunID == !!.run)   }
  # Grab and rename columns according to our template
  q_e = q_e %>% 
    select(c(
      year = "yearID", any_of(vars_geo), pollutant = "pollutantID",
      sourcetype = "sourceTypeID", regclass = "regClassID", 
      fueltype = "fuelTypeID", roadtype = "roadTypeID", 
      emissions = "emissionQuant")) 
  # Process (and collect into local memory) emissions data using the supplied settings
  emissions = process_emissions(tab = q_e, .by = .by, .pollutant = .pollutant, .geoid =  .geoid) 

  metadata$county$activity
  # PROCESS ACTIVITY DATA ######################################################
  # Load function for processing activity data
  # source("R/process_activity.R") 
  
  
  # Access movesoutput table (emissions)
  q_a = con %>% tbl("movesactivityoutput") 
  # If there's a specific run, filter to that run (but it's not required)
  if(!is.null(.run)){ q_a = q_a %>% filter(MOVESRunID == !!.run)   }
  # Grab and rename columns according to our template .m
  q_a = q_a %>% select(
    year = "yearID", any_of(vars_geo), 
    sourcetype = "sourceTypeID", regclass = "regClassID", 
    fueltype = "fuelTypeID", roadtype = "roadTypeID",
    activitytype = "activityTypeID", activity = "activity"
  )
  # Process (and collect into local memory) activity data using the supplied settings
  activity = process_activity(tab = q_a, .by = .by, .geoid = .geoid)
  
  
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
  
  # Return output
  return(result)
}


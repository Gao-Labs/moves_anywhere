#' @name process_emissions
#' @title `process_emissions()`
#' @description
#' This function allows the user/session to connect to one of our frequently used database connections, depending on input criteria.
#' Function to process emissions data for a specific .geoid and .by and .pollutant, (though by default, .pollutant is NULL and we gather data for all pollutants), given a 'tab' - a local connection to a specific table, which is obtained formatted in the process_by.R function.
#' Meant to be used as a sub-function.
#' @param tab  ...
#' @param .by ...
#' @param .geoid ...
#' @param .pollutant ...
#' @importFrom dplyr `%>%` filter mutate summarize left_join tbl collect na_if all_of across group_by if_else any_of ungroup
#' @importFrom tidyr pivot_wider pivot_longer
#' @importFrom stringr str_remove str_split 
#' @importFrom utils data
#' @import DBI
#' @import RSQLite
#' @import RMariaDB
#' @export
#' @author Tim Fraser, March 2023

process_emissions = function(tab, .by, .geoid, .pollutant = NULL){
  # require(dplyr, warn.conflicts = FALSE)
  # require(DBI, warn.conflicts = FALSE)
  # #require(RSQLite, warn.conflicts = FALSE)
  # require(RMariaDB, warn.conflicts = FALSE)
  # require(tidyr, warn.conflicts = FALSE)
  # require(stringr, warn.conflicts = FALSE)
  # #tab = q_e
  # Make type-specific filtering adjustments
  # data = tab %>% filter(roadtype != 1)
  
  # Get starter table queries for emissions and activity levels
  data = tab
  
  # Filter to specific pollutant, if desired
  if(!is.null(.pollutant)){ data = data %>% filter(pollutant %in% !!.pollutant) }
  # Filter to specific geoid, if desired
  if(!is.null(.geoid) & !"00" %in% .geoid ){
    .mygeoid = as.integer(.geoid)
    data = data %>% filter(geoid %in% !!.mygeoid ) 
    # If nation (and a 1 cell call), assign this geoid
  }else if(length(.geoid) == 1 & .geoid[1] == "00"){
    .mygeoid = as.integer(.geoid)
    data = data %>% filter(is.null(geoid)) %>% mutate(geoid = !!.mygeoid)}
  
  # Get variable names....
  # Get categories matching your '.by' id
  cats = get_bycats(.by)
  # Get pollutant, always present
  basic = "pollutant"
  # Set unique ID variables
  ids = c("year", "geoid")
  # Get starter values for aggregation strata
  all = c(ids, basic, cats)

  # Aggregate Emissions
  data = data %>%
    select(all_of(all), emissions) %>%
    group_by(across(.cols = all_of(!!all) )) %>%
    summarize(emissions = sum(emissions, na.rm = TRUE), .groups = "drop") %>%
    # Order variables
    select(all_of(all), emissions) 

  # Get number of spaces for formatting the geoid
  .spaces = nchar(.geoid[1])
  .spaces = if_else(.spaces > 2, true = 5, false = 2)
  
  result = data %>%  
    collect() %>%
    mutate(geoid = stringr::str_pad(geoid, width = .spaces, side = "left", pad = "0"))
  
  return(result)
}
#' @name process_activity
#' @title `process_activity()`
#' @description
#' Function to process activity data for a specific .geoid and .by, 
#' given a 'tab' - a local connection to a specific table, 
#' which is obtained formatted in the process_by.R function.
#' Meant to be used as a sub-function.
#' @param tab ... 
#' @param .by ...
#' @param .geoid ...
#' @importFrom dplyr `%>%` filter mutate summarize left_join tbl collect na_if all_of across group_by if_else any_of ungroup
#' @importFrom tidyr pivot_wider pivot_longer
#' @importFrom stringr str_remove str_split 
#' @importFrom utils data
#' @import DBI
#' @import RMariaDB
#' @export
#' @author Tim Fraser, March 2023

process_activity = function(tab, .by, .geoid){
  # require(dplyr, warn.conflicts = FALSE)
  # require(DBI, warn.conflicts = FALSE)
  # require(RSQLite, warn.conflicts = FALSE)
  # require(RMariaDB, warn.conflicts = FALSE)
  # require(tidyr, warn.conflicts = FALSE)
  # require(stringr, warn.conflicts = FALSE)
  
  # Set unique ID variables
  ids = c("year", "geoid")
  # Get categories matching your '.by' id
  cats = get_bycats(.by)
  # Get starter values for aggregation strata
  all = c(ids, cats)
  # Remove roadtype, which does not apply to some activity metrics
  other_groups = all[!all %in% "roadtype"]
  
  # Get data
  data = tab %>%
    filter( 
      # Activity types that vary by roadtype
      (roadtype != 1 & activitytype %in% c(1, 4)) |
        # Activity types that don't vary by roadtype
        (roadtype == 1 & activitytype %in% c(3,6,7,13,14,15))) %>%
    select(all_of(all), roadtype, activitytype, activity)
  
  # Filter to specific geoid, if desired
  if(!is.null(.geoid) & !"00" %in% .geoid ){
    .mygeoid = as.integer(.geoid)
    data = data %>% filter(geoid %in% !!.mygeoid ) 
    # If nation, assign this geoid
  }else if(length(.geoid) == 1 & .geoid[1] == "00"){
    .mygeoid = as.integer(.geoid)
    data = data %>% filter(is.null(geoid)) %>% mutate(geoid = !!.mygeoid)}
  
  # Aggregate Activity levels that vary by road
  data = data %>%
    select(all_of(all), activitytype, activity) %>%
    group_by(across(.cols = !!all), activitytype) %>%
    summarize(activity = sum(activity, na.rm = TRUE), .groups = "drop")  %>%
    ungroup()
  
  # Get number of spaces for formatting the geoid
  .spaces = nchar(.geoid[1])
  .spaces = if_else(.spaces > 2, true = 5, false = 2)
  
  # Collect now, since it will be faster to pivot outside of sql, I think.
  data = data %>% 
    collect() %>%
    mutate(geoid = stringr::str_pad(geoid, width = .spaces, side = "left", pad = "0"))
  
  # If you are aggregating by roadtype, you'll need this joining strategy
  if("roadtype" %in% all){
    
    r = data %>%
      filter(roadtype != 1 & activitytype %in% c(1, 4)) %>%
      pivot_wider(id_cols = any_of(all), names_from = activitytype, values_from = activity)
    
    nr = data %>%
      filter(roadtype == 1 & !activitytype %in% c(1, 4)) %>%
      pivot_wider(id_cols = any_of(other_groups), names_from = activitytype, values_from = activity)
    
    # Overwrite out_a
    data = r %>% left_join(by = other_groups, y = nr)
    
    # If you are not aggregating by roadtype, you can just sum them all up above and pivot below
  }else{
    data = data %>% 
      pivot_wider(id_cols = any_of(other_groups), 
                  names_from = activitytype, values_from = activity)
  }
  
  # Select, order, and name final set of columns
  data = data %>% 
    select(any_of(ids), any_of(cats),
           any_of(c(vmt = "1", sourcehours = "4", 
                    vehicles = "6", starts = "7",
                    idlehours = "3", hoteld = "13", 
                    hotelb = "14", hotelo = "15")))
  return(data)

}

#' @name read_it
#' @title `read_it()`
#' @description
#' Function to read in a big .csv to contain exactly the data we need, formatted exactly the way we want it.
#' @param path ...
#' @param ... ...
#' @param metadata ...
#' @param .adjust ...
#' @param .storage ...
#' @importFrom dplyr tibble `%>%` as_tibble filter mutate
#' @importFrom stringr str_pad
#' @importFrom purrr possibly
#' @importFrom readr read_csv
#' @importFrom readr cols col_double col_integer col_character
#' @export
#' @author Tim Fraser, March 2023

read_it = function(path, ..., metadata, .adjust = FALSE, .storage = FALSE){
  #require(vroom, warn.conflicts = FALSE)
  #require(purrr, warn.conflicts = FALSE)
  #require(dplyr, warn.conflicts = FALSE)
  #require(stringr, warn.conflicts = FALSE)
  
  # Write a mini-function for speedy importing that we'll use below
  try_it = purrr::possibly(read_csv, otherwise = dplyr::tibble())
  
  # Testing
  
  #metadata = read_rds("formatter/helper/metadata.rds")[["county"]]$emissions
  #path = f$mo[i]
  #.storage = FALSE
  
  # If the goal is storage (storing the .csv in a sqlite server for later analysis)
  if(.storage == TRUE){
    
    # Just grab the columns, as is, without changing their names
    #metadata$types[[2]] <- col_integer()
    data = path %>% 
      try_it(delim = ",",  
             col_select = unname(metadata$vars), 
             col_types = cols(
               "activity" = col_double(),
               "emissionQuant" = col_double(),
               .default = col_integer()) ) %>%
      suppressWarnings() %>%
      dplyr::as_tibble()
    
    # Conditional Filtering
    if("emissionQuant" %in% names(data)){
      data = data %>% dplyr::filter(roadTypeID != 1)
      
    }else if("activity" %in% names(data)){
      data = data %>%
        dplyr::filter( (roadTypeID != 1 & activityTypeID %in% c(1,4)) |
                 (roadTypeID == 1 & activityTypeID %in% c(3,6,7,13,14,15)) ) }

  }else{
    # Otherwise, change the column names
    data = path %>% 
      try_it(..., col_select = metadata$vars, col_types = metadata$types) %>%
      dplyr::as_tibble()    
    var_road = "roadtype"; var_act = "activitytype" 
    
    # If emissions, just cut roadtype emissions. We don't need them.
    if(metadata$type == "emissions"){ data = data %>% dplyr::filter(roadtype != 1) }
    
    # If activity, narrow to just these two sets
    if(metadata$type == "activity"){
      data = data %>%
        # Activity types that vary by roadtype
        dplyr::filter( (roadtype != 1 & activitytype %in% c(1, 4)) |
                  # Activity types that don't vary by roadtype
                  (roadtype == 1 & activitytype %in% c(3,6,7,13,14,15)))
    }
    
    # If adjust = TRUE, run adjustments that require
    if(.adjust){ data = data %>% dplyr::mutate(geoid = stringr::str_pad(geoid, width = 5, side = "left", pad = "0")) }
    
  }
  
  return(data)
}


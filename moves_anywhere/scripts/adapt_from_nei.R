#' adapt_from_nei.R

# A series of functions for adapting inputs from the National Emissions Inventory

# testing values
# setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))
# .geoidchar = "54035"; .year = 2020
# path_hpmsvtypeyear = "scripts/reference/hpmsvtypeyear.csv"
# path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"
# path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv"
# path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"

# HELPER FUNCTIONS --------------------------------------------

# Let's write a customized approx() function
approxit = function(x, y, xout){
  n_x = length(x)
  
  # Is xout within the min or max of x
  within = xout >= min(x) & xout <= max(x)
  
  # If the value xout is actually within the interval of x, interpolate it... 
  if(n_x >= 2 & within == TRUE){
    # go and do approx
    yright = y[x == max(x, na.rm = TRUE)][1]
    yleft = y[x == min(x, na.rm = TRUE)][1]
    m = approx(x = x, y = y, xout = xout, method = "linear", yright = yright, yleft = yleft, na.rm = TRUE)
    return(m$y)    
    
    # If just 1 value is available and the prediction value being asked for is that specific year, just return y
  }else if(n_x == 1 & all(xout == x) ){ return(y) 
    
    # If just 1 value is available, but the prediction value asked for is not that specific year...
  }else if(n_x == 1 & !all(xout == x)){
    # What if just 1 value is available BUT the prediction value being asked for is NOT that specific year?
    # Eg. just 2011 is available, but they are asking for 2050
    # then we really should be using a predictive model instead.
    # We'll make this particular version return NAs.
    return(NA_real_)
  }else{
    # Otherwise, some other issue appeared and we should be cautious, so return NA
    return(NA_real_)
  }
  
}
#' @name get_vmt1b
#' @description
#' Interpolate VMT from NEI data WITHIN NEI YEAR RANGE, using a linear model of JUST that year (problem!)
#' @param .geoidchar 5-digit county geoid
#' @param .year year for which you want predictions
#' @param .yearofinterest year of NEI data off which you want to base those predictions
get_vmt1b = function(.geoidchar, .year, .yearinterest, path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"){
  
  current = read_rds(path_nei_sourcetypeyearvmt) %>%
    filter(geoid == .geoidchar) %>%
    filter(year %in% .yearofinterest)
  
  data = current %>%
    group_by(sourcetype) %>%
    summarize(vmt = lm(formula = vmt ~ year) %>% 
                predict(newdata = tibble(year = .year)),
              year = .year, .groups = "drop")
  
  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
  
  return(final)      
}

#' @name get_vmt1
#' @description
#' Interpolate VMT from NEI data WITHIN NEI YEAR RANGE, using `approx()`-based linear interpolation for that year, from all NEI data.
#' @param .geoidchar 5-digit county geoid
#' @param .year year for which you want predictions
get_vmt1 = function(.geoidchar, .year, path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"){
  
  data = read_rds(path_nei_sourcetypeyearvmt) %>%
    filter(geoid == .geoidchar) %>%
    group_by(sourcetype) %>%
    summarize(
      vmt = approxit(x = year, y = vmt, xout = .year),
      year = .year
    )
  
  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
  
  return(final)
}

#' @name get_vmt2
#' @description
#' Helper function to approximate for 1 geoid the values available OUTSIDE the NEI data-availability time frame
#' Assumes (1) that your geoid is measured at SOME POINT IN THE NEI DATA
#' Assumes (2) that your true vmt distribution in year X will be appropriately modeled
#'             using the geographic variation from the NEI dataset and the temporal variation from the MOVES default database
#' @param .year year of prediction
#' @param .yearofinterest year from which source data will be drawn/interpolated 
get_vmt2 = function(.geoidchar, .year, .yearofinterest, path_hpmsvtypeyear = "scripts/reference/hpmsvtypeyear.csv",  path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"){
  # testing values
  # path_hpmsvtypeyear = "scripts/reference/hpmsvtypeyear.csv";  path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"
  # .year = 2022; .geoidchar = "36109"; .yearofinterest = 2020
  
  # Get the nationwide total estimate of VMT for the current year
  current = read_csv(path_hpmsvtypeyear, show_col_types = FALSE) %>%
    filter(yearID == .year) %>%
    select(hpmsvtype = HPMSVtypeID, year = yearID, vmt_total = HPMSBaseYearVMT)
  
  
  # What's the ratio of vmt in YOUR county for that sourcetype to the WHOLE COUNTY for that year
  reference = read_rds(path_nei_sourcetypeyearvmt) %>%
    filter(year == .yearofinterest) %>%
    group_by(sourcetype) %>%
    summarize(
      vmt_geoid = sum(vmt[geoid == .geoidchar], na.rm = TRUE),
      vmt_any = sum(vmt, na.rm = TRUE)
    ) %>%
    mutate(hpmsvtype = sourcetype %>% dplyr::recode(
      "11" = 10,
      "21" = 25,
      "31" = 25,
      "32" = 25,
      "41" = 40,
      "42" = 40,
      "43" = 40,
      "51" = 50,
      "52" = 50,
      "53" = 50,
      "54" = 50,
      "61" = 60,
      "62" = 60
    )) %>%
    # Now calculate the total VMT per HPMSVtype
    group_by(hpmsvtype) %>%
    mutate(vmt_hpms = sum(vmt_any, na.rm = TRUE)) %>%
    ungroup() %>%
    # Now calculate the RATIO of vmt_geoid vs. vmt_hpms for reference year
    # If we can get the total VMT hpms for actual year, 
    # we should be able to approximate
    # the expected VMT geoid for that sourcetype in the actual year
    mutate(ratio  = vmt_geoid / vmt_hpms ) %>%
    # Join in the expected VMT total for each hpmsvtype in actual year
    left_join(by = c("hpmsvtype"), y = current) %>% 
    # multiply by ratio to get expected VMT geoid for that sourcetype
    mutate(vmt = ratio * vmt_total)
  
  # Format
  output = reference %>%
    select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
  
  return(output)
}






#' @name get_vehicles0
#' @description
#' Helper function to grab the exact NEI vehicle count estimates, assuming that your geoid and year are represented there.
get_vehicles0 = function(.geoidchar, .year, path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"){
  # Just filter to obtain the estimate    
  data = read_rds(path_nei_sourcetypeyear) %>%
    filter(geoid == .geoidchar) %>%
    filter(year %in% .year)
  
  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
  
  return(final)
}




#' @name get_vehicles1
#' @description
#' Helper function to approximate for 1 geoid the values available within the NEI data-availability time frame
#' Requires at least 2 values per sourcetype available for that geoid
#' If the year is out of the NEI data availability time frame, it will return the max or min year's vehicle value
#' Good for when you know some-but-not-all the values within the available time.frame
get_vehicles1 = function(.geoidchar, .year, path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"){
  # .geoidchar = "29137"; .year = 2011;
  # path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv";
  # path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds";
  # path_projections = "scripts/projections.rds"

  # Get the most recent approximate details
  reference = read_rds(path_nei_sourcetypeyear) %>%
    filter(geoid == .geoidchar)
  
  data = reference %>%
    # interpolate a value for each of those sourcetypes
    group_by(sourcetype) %>%
    summarize(vehicles = approxit(x = year, y = vehicles, xout = .year), year = .year)
  

  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
  return(final)
}

#' @name get_vehicles1b
#' @description
#' Helper function to linearly interpolate vehicle counts for your county by sourcetype
#' using NEI data available for the `.yearofinterest` of interest,
#' interpolating it for the `.year` of interest.
get_vehicles1b = function(.year = 2019, .yearofinterest = c(2017, 2020), .geoidchar = "36109", path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"){
  
  # Import in that geoid's NEI data for the year range available
  current = read_rds(path_nei_sourcetypeyear) %>%
    filter(geoid == .geoidchar) %>%
    filter(year %in% .yearofinterest)
  
  # Interpolate the vehicle estimates for that year.
  final = current %>%
    group_by(sourcetype) %>%
    summarize(vehicles = lm(formula = vehicles ~ year) %>% 
                predict(newdata = tibble(year = .year)),
              year = .year, .groups = "drop") %>%
    select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
  return(final)
}

#' @name get_vehicles2
#' @description
#' Helper function to approximate for 1 geoid the values availabe OUTSIDE the NEI data-availability time frame
#' Assumes (1) that your geoid is measured at SOME POINT IN THE NEI DATA
#' Assumes (2) that your true vehicle distribution in year X will be appropriately modeled
#'             using the geographic variation from the NEI dataset and the temporal variation from the MOVES default database
get_vehicles2 = function(.geoidchar = "36109", .year = 2022, .yearofinterest = 2020, path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv", path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"){
  
  # Load in the MOVES default nationwide vehicle count for that year
  current = read_csv(path_sourcetypeyear, show_col_types = FALSE) %>%
    filter(yearID == .year) %>%
    select(sourcetype = sourceTypeID, year = yearID, vehicles_total = sourceTypePopulation)
  
  # Next, we're going to weight that vehicle count by the most recently available
  # ratio of your county's vehicles to the nation's vehicle count, per sourcetype
  
  # What's the ratio of vehicles in YOUR county for that sourcetype to the WHOLE COUNTY for that year
  reference = read_rds(path_nei_sourcetypeyear) %>%
    filter(year %in% .yearofinterest) %>%
    group_by(sourcetype) %>%
    summarize(
      vehicles_geoid = sum(vehicles[geoid == .geoidchar], na.rm = TRUE),
      vehicles_sourcetype = sum(vehicles, na.rm = TRUE)
    ) %>%
    mutate(ratio  = vehicles_geoid / vehicles_sourcetype ) %>%
    # Join in the expected Vehicles total for each sourcetype in actual year
    left_join(by = c("sourcetype"), y = current) %>% 
    # multiply by ratio to get expected Vehicles geoid for that sourcetype
    mutate(vehicles = ratio * vehicles_total)
  
  final = reference %>%
    select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
  
  return(final)
}


# What if you have NO PRIOR NEI data on this geoid, but you DO know about its population and nation MOVES defaults.
# Well, let's make some approximations
# Predict the real VMT based on the projected population, land area, and year
# Create a miniature VMT predictor based on the observed NEI data

#' @name get_vmt3
#' @description
#' Helper function to get VMT estimates if you need VMT for a certain `.geoidchar` BUT there are no NEI records available for that `.geoidchar`.
#' Estimates linear models of NEI data over time, accounting for population, land area,  year, and state. Projects values using that.
#' Intended as a last-ditch attempt
get_vmt3 = function(.geoidchar, .year, .sourcetypes = c(11,21,31,32,41,42,43,51,52,53,54,61,62), path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds", path_projections = "scripts/projections.rds"){
  
  # .year = 2022; .geoidchar = "36109";  .sourcetypes = c(11,21,31,32,41,42,43,51,52,53,54,61,62)
  message(paste0("---Using population and area based projections for sourcetypeyearvmt, for sourcetypes: ", paste0(.sourcetypes, collapse = ",")))
    
  newdata = read_rds(path_projections) %>%
    filter(geoid == .geoidchar, year == .year) %>%
    select(geoid, year, pop, area_land) %>%
    mutate(state = stringr::str_sub(geoid, 1,2))
  
  data = read_rds(path_nei_sourcetypeyearvmt) %>%
    # filter to desired sourcetypes
    filter(sourcetype %in% .sourcetypes) %>%
    left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
    mutate(state = stringr::str_sub(geoid, 1,2)) %>%
    group_by(sourcetype) %>%
    reframe(
      { m = lm(formula = log(vmt + 1) ~ log(pop + 1) + log(area_land + 1) + state)
        # Predict using values for that sourcetype
        vmt = predict(m, newdata = newdata) %>% exp() - 1
        year = .year        
        tibble(vmt = vmt, year = year)        
      }
    ) %>%
    # Data cleaning - make sure no negative values  
    mutate(vmt = if_else(vmt < 0, true = 0, false = vmt))
  
  # Format
  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
  
  return(final)
}



#' @name get_vehicles3
#' @description
#' Helper function to get vehicle count estimates if you need vehicles for a certain `.geoidchar` BUT there are no NEI records available for that `.geoidchar`.
#' Estimates linear models of NEI data over time, accounting for population, land area,  year, and state. Projects values using that.
#' Intended as a last-ditch attempt
get_vehicles3 = function(.geoidchar, .year, .sourcetypes = c(11,21,31,32,41,42,43,51,52,53,54,61,62), path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds", path_projections = "scripts/projections.rds"){

  message(paste0("---Using population and area based projections for sourcetypeyearvmt, for sourcetypes: ", paste0(.sourcetypes, collapse = ",")))
  
  # test values
  # .geoidchar = "36109"; .year = 2025; path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"; path_projections = "scripts/projections.rds"
  
  newdata = read_rds(path_projections) %>%
    filter(geoid == .geoidchar, year == .year) %>%
    select(geoid, year, pop, area_land) %>%
    mutate(state = stringr::str_sub(geoid, 1,2))

  data = read_rds(path_nei_sourcetypeyear) %>%
    # Filter only to desired sourcetypes
    filter(sourcetype %in% .sourcetypes) %>%
    # Join population projections
    left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
    # Aquire a state identifier
    mutate(state = stringr::str_sub(geoid, 1,2)) %>%
    # Per sourcetype, predict vehicles
    group_by(sourcetype) %>%
    reframe(
      vehicles = lm(formula = log(vehicles + 1) ~ log(pop + 1) + log(area_land + 1) + state) %>% 
        predict(newdata = newdata) %>% exp() - 1,
      year = .year
    ) %>%
    # Data cleaning - make sure no negative values  
    mutate(vehicles = if_else(vehicles < 0, true = 0, false = vehicles))
  
  final = data %>%
    select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
  
  return(final)
}




# FUNCTIONS -------------------------------------------------------

adapt_vmt_from_nei = function(
    .geoidchar = "36109",
    .year = 2022,
    path_hpmsvtypeyear = "scripts/reference/hpmsvtypeyear.csv",
    path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds",
    path_projections = "scripts/projections.rds"
){
  
  # Load required packages
  library(readr, quietly = TRUE, warn.conflicts = FALSE)
  library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
  
  # Get available years - DEPRECATED
  # years = read_rds(path_nei_sourcetypeyearvmt)$year %>% unique()
  
  # Get available years FOR THAT GEOID
  years = read_rds(path_nei_sourcetypeyearvmt) %>%
    filter(geoid == .geoidchar) %>%
    with(year) %>% unique() %>% sort()
  
  # Get number of years of NEI data available for that GEOID
  n_years = length(years)
  
  # If any years of NEI data available...
  if(n_years > 0){    
    
    if(all(.year > years)){
      .yearofinterest = max(years)
      interpolate = FALSE
    }else if(all(.year < years)){
      .yearofinterest = min(years)
      interpolate = FALSE
    }else{
      # # Find the lowest year that is greater than or equal to the current year 
      # upper = min(years[.year <= years])
      # # Find the highest year that is less than or equal to the current year
      # lower = max(years[.year >= years])
      # # We will interpolate between these two data points to get your estimates
      # .yearofinterest = c(lower, upper)
      .yearofinterest = .year
      interpolate = TRUE
    }
    
    
    if(interpolate == TRUE){
      
      # For example: 
      # Interpolate year 2019, inside NEI timeframe 2011-2020
      # get_vmt1(.geoidchar = "36109", .year = 2019)
      output = get_vmt1(.geoidchar = .geoidchar, .year = .yearofinterest, path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt)
      
      # DEPRECATED
      # output = get_vmt1b(.geoidchar = .geoidchar, .year = .year, .yearofinterest = .yearofinterest,  path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt)
      
      
    }else if(interpolate == FALSE){
      # For example:
      # Calculate year 2023, weighting by geographic variation data from the most recent available NEI year 2020
      # get_vmt2(.geoidchar = "36109", .year = 2023, .yearofinterest = 2020)
      output = get_vmt2(.geoidchar = .geoidchar, .year = .year, .yearofinterest = .yearofinterest, path_hpmsvtypeyear = path_hpmsvtypeyear, path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt)
      
    }
    
  }else{
    # If no years of NEI data available, approximate NEI-like predictions instead using population and area 
    output = get_vmt3(.geoidchar = .geoidchar, .year = .year, path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt, path_projections = path_projections)  
  }

  # If you get to the end, and output has problems, use get_vmt3
  n_output = nrow(output)
  if(n_output == 0){
    # If no years of NEI data available, approximate NEI-like predictions instead using population and area 
    output = get_vmt3(.geoidchar = .geoidchar, .year = .year, path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt, path_projections = path_projections)  
  }
  
  # If there are any values that are missing...
  n_missing = sum(is.na(output$VMT)) > 0
  if(n_missing > 0){
    # Aquire the missing sourcetypes
    .sourcetypes = output %>% filter(is.na(VMT)) %>% with(sourceTypeID)
    # Get VMT estimates for those missing values
    output_fixed = get_vmt3(.geoidchar = .geoidchar, .year = .year,.sourcetypes = .sourcetypes, path_nei_sourcetypeyearvmt = path_nei_sourcetypeyearvmt, path_projections = path_projections)  
    # Bind them together nicely
    output = bind_rows(
      output %>% filter(!is.na(VMT)),
      output_fixed)
  }
  
  return(output)  
}




adapt_vehicles_from_nei = function(
    .geoidchar = "36109",
    .year = 2022,
    path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv",
    path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds",
    path_projections = "scripts/projections.rds"
){
  # testing vavlue
  # .geoidchar = "29137"; .year = 2011; 
  # path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv";
  # path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds";
  # path_projections = "scripts/projections.rds"

  # Load required packages
  library(readr, quietly = TRUE, warn.conflicts = FALSE)
  library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
  
  # Get available years FOR THAT GEOID
  years = read_rds(path_nei_sourcetypeyear) %>%
    filter(geoid == .geoidchar) %>%
    with(year) %>% unique() %>% sort()
  
  
  # years = read_rds(path_nei_sourcetypeyear)$year %>% unique()
  
  
  # Get number of years of NEI data available for that GEOID
  n_years = length(years)
  # If any years of NEI data available...
  if(n_years > 0){    
    
    
    # If year .year is in the available years...
    if(.year %in% years){
      
      .yearofinterest = .year
      # technically, we set interpolate = TRUE because 
      # approx() from get_vehicles1 still provides exact results,
      # but is more error-proof than a direct filter.
      interpolate = TRUE
      
      # If your year is less than all the available years, grab the most recent year...
    }else if(all(.year > years)){
      .yearofinterest = max(years)
      interpolate = FALSE
      
      # If your year is greater than all the available years, grab the most recent year
    }else if(all(.year < years)){
      .yearofinterest = min(years)
      interpolate = FALSE
      
      # If your year is in between the year range, but not directly equal to one, we'll interpolate
    }else{
      # Find the lowest year that is greater than or equal to the current year 
      # upper = min(years[.year <= years])
      # Find the highest year that is less than or equal to the current year
      # lower = max(years[.year >= years])
      # We will interpolate between these two data points to get your estimates
      # .yearofinterest = c(lower, upper)
      .yearofinterest = .year
      interpolate = TRUE
    }
    
    
    # If interpolation is needed (between years)
    if(interpolate == TRUE){
      
      # For example:
      # Automatically find whatever exact NEI data is available and return it
      # get_vehicles1(.geoidchar = "36109", .year = 2017)
      
      # OR
      
      # For example:
      # Automatically find whatever NEI data is available and linearly interpolates between those two points
      # get_vehicles1(.geoidchar = "36109", .year = 2018)
      output = get_vehicles1(.geoidchar = .geoidchar, .year = .yearofinterest, 
                             path_nei_sourcetypeyear = path_nei_sourcetypeyear)
      
      # Otherwise...
    }else if(interpolate == FALSE){
      
      # For example: 
      # get_vehicles2(.geoidchar = "36109", .year = 2022, .yearofinterest = 2020)
      output = get_vehicles2(.geoidchar = .geoidchar, .year = .year, .yearofinterest = .yearofinterest, 
                             path_sourcetypeyear = path_sourcetypeyear,
                             path_nei_sourcetypeyear = path_nei_sourcetypeyear)
      
    }
    
    
  }else{
    # If no years of NEI data available, approximate NEI-like predictions instead using population and area 
    output = get_vehicles3(.geoidchar = .geoidchar, .year = .year, path_nei_sourcetypeyear = path_nei_sourcetypeyear, path_projections = path_projections)  
  }
  

  # Are there any NAs?
  
  
  # If you get to the end, and output has problems, use get_vmt3
  n_output = nrow(output)
  if(n_output == 0){
    # If no years of NEI data available, approximate NEI-like predictions instead using population and area 
    output = get_vehicles3(.geoidchar = .geoidchar, .year = .year, path_nei_sourcetypeyear = path_nei_sourcetypeyear, path_projections = path_projections)  
  }

  
  
  # If there are any values that are missing...
  n_missing = sum(is.na(output$sourceTypePopulation)) > 0
  if(n_missing > 0){
    # Aquire the missing sourcetypes
    missing =  output %>% filter(is.na(sourceTypePopulation))
    .sourcetypes = missing$sourceTypeID
    # Get vehicle count estimates for those missing values
    output_fixed = get_vehicles3(.geoidchar = .geoidchar, .year = .year,.sourcetypes = .sourcetypes, path_nei_sourcetypeyear = path_nei_sourcetypeyear, path_projections = path_projections)  
    # Bind them together nicely
    output = bind_rows(
      output %>% filter(!is.na(sourceTypePopulation)),
      output_fixed)
  }
  
  return(output)
  
}




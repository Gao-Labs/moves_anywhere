#' adapt_from_nei.R

# A series of functions for adapting inputs from the National Emissions Inventory

adapt_vmt_from_nei = function(
    .geoidchar = "36109",
    .year = 2022,
    path_hpmsvtypeyear = "scripts/reference/hpmsvtypeyear.csv",
    path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"
){
  
  # Load required packages
  library(readr, quietly = TRUE, warn.conflicts = FALSE)
  library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
  
  # Get available years
  years = read_rds(path_nei_sourcetypeyearvmt)$year %>% unique()
  
  if(all(.year > years)){
    .yearofinterest = max(years)
    interpolate = FALSE
  }else if(all(.year < years)){
    .yearofinterest = min(years)
    interpolate = FALSE
  }else{
    # Find the lowest year that is greater than or equal to the current year 
    upper = min(years[.year <= years])
    # Find the highest year that is less than or equal to the current year
    lower = max(years[.year >= years])
    # We will interpolate between these two data points to get your estimates
    .yearofinterest = c(lower, upper)
    interpolate = TRUE
  }
  
  
  if(interpolate == TRUE){
    
    current = read_rds(path_nei_sourcetypeyearvmt) %>%
      filter(geoid == .geoidchar) %>%
      filter(year %in% .yearofinterest)
    
    final = current %>%
      group_by(sourcetype) %>%
      summarize(vmt = lm(formula = vmt ~ year) %>% 
                  predict(newdata = tibble(year = .year)),
                year = .year, .groups = "drop") %>%
      select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
    
    
  }else if(interpolate == FALSE){
    
    # Get the nationwide total estimate of VMT for the current year
    current = read_csv(path_hpmsvtypeyear) %>%
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
    final = reference %>%
      select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
  }
  return(final)
}

# adapt_vmt_from_nei(
#     .geoidchar = "36109",
#     .year = 2018,
#      path_hpmsvtypeyear = "defaults/hpmsvtypeyear.csv",
#     path_nei_sourcetypeyearvmt = "dev/nei_sourcetypeyearvmt.rds"
# )


adapt_vehicles_from_nei = function(
    .geoidchar = "36109",
    .year = 2022,
    path_sourcetypeyear = "scripts/reference/sourcetypeyear.csv",
    path_nei_sourcetypeyear = "scripts/reference/nei_sourcetypeyear.rds"
){
  
  # Load required packages
  library(readr, quietly = TRUE, warn.conflicts = FALSE)
  library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
  
  # Get available years
  years = read_rds(path_nei_sourcetypeyear)$year %>% unique()
  
  # If year year is in the available years...
  if(.year %in% years){
    
    # Just filter to obtain the estimate    
    final = read_rds(path_nei_sourcetypeyear) %>%
      filter(geoid == .geoidchar) %>%
      filter(year %in% .yearofinterest) %>%
      select(yearID = year, sourceTypeID = sourcetype, sourceTypePopulation = vehicles)
    return(final)
    
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
    upper = min(years[.year <= years])
    # Find the highest year that is less than or equal to the current year
    lower = max(years[.year >= years])
    # We will interpolate between these two data points to get your estimates
    .yearofinterest = c(lower, upper)
    interpolate = TRUE
  }
  
  
  # If interpolation is needed (between years)
  if(interpolate == TRUE){
    
    final = current %>%
      group_by(sourcetype) %>%
      summarize(vmt = lm(formula = vmt ~ year) %>% 
                  predict(newdata = tibble(year = .year)),
                year = .year, .groups = "drop") %>%
      select(yearID = year, sourceTypeID = sourcetype, VMT = vmt)
    return(final)
    
    # Otherwise...
  }else if(interpolate == FALSE){
    
    
    current = read_csv(path_sourcetypeyear, show_col_types = FALSE) %>%
      filter(yearID == .year) %>%
      select(sourcetype = sourceTypeID, year = yearID, vehicles_total = sourceTypePopulation)
    
    
    # What's the ratio of vehicles in YOUR county for that sourcetype to the WHOLE COUNTY for that year
    reference = read_rds(path_nei_sourcetypeyear) %>%
      filter(year == .yearofinterest) %>%
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
}





# adapt_vmt.R

# This script's function picks from any of these 4 tables and selects the most appropriate, if multiple are provided.
# Only 1 of these 4 next tables can be uploaded at one time.
# - sourcetypedayvmt
# - hpmsvtypeday 
# - sourcetypeyearvmt 
# - hpmsvtypeyear 

adapt_vmt = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .year = rs$year
  .month = rs$month # eg. 1:12,
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .custom = rs$defaultdbname
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Only one of these next 4 tables can be uploaded at one time.
  # Suppose this is our changed vector
  # .changed = c("sourcetypeyearvmt", "hpmsvtypeyear", "bird")
  
  # First, check if MULTIPLE TABLES are uploaded.
  items = c("sourcetypeyearvmt", "sourcetypedayvmt", "hpmsvtypeyear", "hpmsvtypeday")
  # Find me the items that meet our criteria and are in .changed  
  myitems = items[items %in% files$changed]
  # How many were uploaded
  n_uploaded = sum(items %in% files$changed)
  
  
  # If multiple tables uploaded,  
  if(n_uploaded > 1){
    # Warn the user - we can only use one.
    cat(paste0("\n\n---WARNING: Multiple tables uploaded for section VEHICLE TYPE VMT when only 1 is allowed at a time. Overlapping tables: ", paste0(myitems, collapse = ", "), "\n"))
    cat("\nWill prioritize tables in this order: sourcetypedayvmt, hpmsvtypeday, sourcetypeyearvmt, hpmsvtypeyear\n")
    cat("\nIf this is a problem, remove the extra tables from inputs.\n\n")
    
    # We already uploaded the tables above, so we will DROP the less preferrable ones here.
    # IF "sourcetypedayvmt" is available...
    if("sourcetypedayvmt" %in% files$changed){
      item_to_keep = "sourcetypedayvmt"
      # OTHERWISE, if "hpmsvtypeday" is available...
    }else if("hpmsvtypeday" %in% files$changed){
      item_to_keep = "hpmsvtypeday"
      # OTHERWISE, if "sourcetypeyearvmt" is available...
    }else if("sourcetypeyearvmt" %in% files$changed){
      item_to_keep = "sourcetypeyearvmt"
      # OTHERWISE, if "hpmsvtypeyear" is available...
    }else if("hpmsvtypeyear" %in% files$changed){ 
      item_to_keep = "hpmsvtypeyear"
    }
    
    # If one was updated, we'll use it.
  }else if(n_uploaded == 1){
    item_to_keep = myitems
    # If none were updated, we'll use this as our default
  }else if(n_uploaded == 0){
    item_to_keep = "hpmsvtypeyear"
  }
  
  
  # Narrow in dataframe
  f = get_is_custom(files, table = item_to_keep)
  
  if(f$is_custom){
    # Now load in that item...
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    if(item_to_keep == "sourcetypedayvmt"){
      # get_names("sourcetypedayvmt")
      # Select final columns
      data = data %>% 
        select(
          "yearID" = "yearid",
          "monthID" = "monthid",
          "dayID" = "dayid",
          "sourceTypeID" = "sourcetypeid",
          "VMT" = "vmt"
        )
    }else if(item_to_keep == "hpmsvtypeday"){
      # get_names("hpmsvtypeday")
      data = data %>% 
        select(
          "yearID" = "yearid",
          "monthID" = "monthid",
          "dayID" = "dayid",
          "HPMSVtypeID" = "hpmsvtypeid",
          "VMT" = "vmt"
        )
      
    }else if(item_to_keep == "sourcetypeyearvmt"){
      # get_names("sourcetypeyearvmt")
      data = data %>% 
        select(
          "yearID" = "yearid",
          "sourceTypeID" = "sourcetypeid",
          "VMT" = "vmt"
        )
    }else if(item_to_keep == "hpmsvtypeyear"){
      # get_names("hpmsvtypeyear")
      data = data %>% 
        select(
          "HPMSVtypeID" = "hpmsvtypeid",
          "yearID" = "yearid",
          "VMTGrowthFactor" = "vmtgrowthfactor",
          "HPMSBaseYearVMT" = "hpmsbaseyearvmt"
        )
    }
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    
    # If that table is not available, we will create it from defaults!
  }else if(!f$is_custom){
    
    # Testing values
    # .year = 2023; .geoid = 36109
    # data = translators::inputs$hpmsvtypeyear
    # Connect to database
    custom = connect("mariadb", .custom)
    # Query
    data = custom %>% tbl("hpmsvtypeyear") %>% collect()
    # Disconnect
    dbDisconnect(custom)
    
    # Linearly interpolate HPMSBaseYearVMT for any missing years
    data = data %>%
      group_by(HPMSVtypeID) %>%
      reframe(year_range = 1990:2060,
              # Set to 0; no longer used
              VMTGrowthFactor = 0,
              HPMSBaseYearVMT = approx(x = yearID, y = HPMSBaseYearVMT, xout = year_range)$y
      ) %>%
      rename(yearID = year_range) 
    
    # And re-weight it
    estimates = catr::projections %>%
      filter(year == .year & geoid == .geoidchar)
    
    # Reweight the sourceTypePopulation by that year-geoid pair's projected ratio.
    data = data %>%
      filter(yearID == .year) %>%
      # Join in the population estimates for the scenario year
      left_join(by = c("yearID" = "year"), 
                y = estimates %>% select(year, fraction)) %>%
      # Weight the sourcetypepopulation by the county population vs. national population ratio
      mutate(HPMSBaseYearVMT  = HPMSBaseYearVMT  * fraction) %>%
      # Get required variables
      select(HPMSVtypeID, yearID, VMTGrowthFactor, HPMSBaseYearVMT )
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }    
  
  
  # Drop extra tables 
  # Get the items that ARE NOT the one we selected
  items_to_drop = items[!items %in% item_to_keep]
  # For each item to drop, truncate that table
  if(length(items_to_drop) > 0){
    custom = connect("mariadb", .custom)
    for(i in items_to_drop){ DBI::dbExecute(custom, statement = paste0("TRUNCATE TABLE ", i, ";")) }
    dbDisconnect(custom)
  }
  
  
}

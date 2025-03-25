adapt_starts = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "starts"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .year = rs$year
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  # If provided, use and filter that
  if(f$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$starts %>% names()
    # Select final columns
    data = data %>% 
      select(hourDayID = hourdayid, 
             monthID = monthid,
             yearID = yearid,
             ageID = ageid,
             zoneID = zoneid,
             sourceTypeID = sourcetypeid,
             starts = starts,
             StartsCV = startscv,
             isUserInput = isuserinput) %>%
             # If you provided this, isUserInput must be YES
      mutate(isUserInput = "Y")
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = FALSE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # By default, it is EMPTY
    # Query
    data = custom %>% tbl(table) %>% 
      filter(yearID %in% !!.year) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)

    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}



adapt_startshourfraction = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "startshourfraction"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .year = rs$year
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  # If provided, use and filter that
  if(f$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$startshourfraction %>% names()
    # Select final columns
    data = data %>% 
      select(dayID = dayid, 
             hourID = hourid,
             sourceTypeID = sourcetypeid,
             allocationFraction = allocationfraction)
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = FALSE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # Query
    data = custom %>% tbl(table) %>% 
      filter(dayID %in% !!.day, 
             hourID %in% !!.hour) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)

    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}


adapt_startsperday = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "startsperday"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .year = rs$year
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  # If provided, use and filter that
  if(f$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$startshourfraction %>% names()
    # Select final columns
    data = data %>% 
      select(dayID = dayid, 
             sourceTypeID = sourcetypeid,
             startsPerDay = startsperday)
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = FALSE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # By default it is EMPTY
    # Query
    data = custom %>% tbl(table) %>% 
      filter(dayID %in% !!.day) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)

    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}



adapt_startsperdaypervehicle = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "startsperdaypervehicle"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .year = rs$year
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  # If provided, use and filter that
  if(f$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$startshourfraction %>% names()
    # Select final columns
    data = data %>% 
      select(dayID = dayid, 
             sourceTypeID = sourcetypeid,
             startsPerDayPerVehicle = startsperdaypervehicle)
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = FALSE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # By default it is NOT empty
    # Query
    data = custom %>% tbl(table) %>% 
      filter(dayID %in% !!.day) %>%
      collect()
    # Disconnect
    dbDisconnect(custom)
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}
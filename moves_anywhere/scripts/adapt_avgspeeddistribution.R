adapt_avgspeeddistribution = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "avgspeeddistribution"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
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
    
    # Select final columns
    data = data %>% 
      select(sourceTypeID = sourcetypeid, 
             roadTypeID = roadtypeid,
             hourDayID = hourdayid,
             avgSpeedBinID = avgspeedbinid,
             avgSpeedFraction = avgspeedfraction)
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # must not filter by roadtype here
    # Query
    data = custom %>% tbl(table) %>% 
      filter(hourDayID %in% !!.hourday) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}

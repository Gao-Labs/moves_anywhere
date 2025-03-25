adapt_startsopmodedistribution = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  ### startsopmodedistribution #################################  
  table = "startsopmodedistribution"
  
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  if(!table %in% files$changed){
    # Tentatively, if default, just skip. Use the defaults, no filtering.
    # Connect
    # custom = connect("mariadb", .custom)
    # Query
    # data = custom %>% tbl("startsopmodedistribution") %>% filter(opModeID %in% !!ids$opModeID, dayID %in% !!.day, hourID %in% !!.hour) %>% collect()
    # dbDisconnect(custom)
    # Import table!
    # import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "startsopmodedistribution")
    data = data %>% 
      select(
        "dayID" = "dayid",
        "hourID" = "hourid",
        "sourceTypeID" = "sourcetypeid",
        "ageID" = "ageid",
        "opModeID" = "opmodeid",
        "opModeFraction" = "opmodefraction",
        "isUserInput" = "isuserinput"
      ) %>%
      mutate(isUserInput = "Y") # clarify that it is user-input
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
}
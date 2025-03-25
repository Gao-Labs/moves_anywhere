adapt_totalidlefraction = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "totalidlefraction"
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
  
  if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "totalidlefraction")
    data = data %>% 
      select(
        "sourceTypeID" = "sourcetypeid",
        "minModelYearID" = "minmodelyearid",
        "maxModelYearID" = "maxmodelyearid",
        "monthID" = "monthid",
        "dayID" = "dayid",
        "idleRegionID" = "idleregionid",
        "countyTypeID" = "countytypeid",
        "totalIdleFraction" = "totalidlefraction"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
}
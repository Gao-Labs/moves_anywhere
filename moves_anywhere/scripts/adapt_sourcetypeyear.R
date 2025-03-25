# adapt_sourcetypeyear.R

# Script to adapt sourcetypeyear table

adapt_sourcetypeyear = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "sourcetypeyear"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .geoid = rs$geoid
  .year = rs$year
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")

  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Check if that custom input table is provided among the provided input tables
  f = files %>% filter(changed == table)
  # Get number of matching tables
  f_n = nrow(f)
  # Error handling
  if(f_n > 1){ stop("Multiple MOVES input files of the same name provided. Stopping...")}
  
  # Is the table of interest provided as a custom input file?
  is_custom = f_n == 1
  
  # If provided, use and filter that
  if(is_custom){
    # Load in data    
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)

    # Filter by year
    data = data %>% filter(yearid == .year)    

    # Select final columns
    data = data %>% 
      select(yearID = yearid, sourceTypeID = sourcetypeid, sourceTypePopulation = sourcetypepopulation)
    # Test out
    # data = data %>%
    #   mutate(sourceTypePopulation = sourceTypePopulation * 100)
    
    # Import the table
    import_table(data = data, tablename = table, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    
    # If not provided, estimate a default
  }else if(!is_custom){
    
    # Connect to database
    custom = connect("mariadb", .custom)
    
    data = custom %>% 
      tbl("sourcetypeyear") %>%
      filter(yearID == !!.year) %>%
      select(yearID, sourceTypeID, sourceTypePopulation) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)
    
    # For that geoid
    estimates = catr::projections %>%
      filter(year == .year & geoid == .geoidchar)
    
       # Overwrite data 
    data = data %>%
      # Reset the year to be whatever year our scenario is
      # mutate(yearID = .year) %>%
      # Join in the population estimates for the scenario year
      left_join(by = c("yearID" = "year"), 
                y = estimates %>% select(year, fraction)) %>%
      # Weight the sourcetypepopulation by the county population vs. national population ratio
      mutate(sourceTypePopulation = sourceTypePopulation * fraction) %>%
      # Get required variables
      select(yearID, sourceTypeID, sourceTypePopulation)
  
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)

  }
  
    
}

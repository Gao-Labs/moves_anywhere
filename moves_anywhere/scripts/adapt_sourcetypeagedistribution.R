adapt_sourcetypeagedistribution = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "sourcetypeagedistribution"
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .year = rs$year
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
      select(sourceTypeID = sourcetypeid, yearID = yearid,
             ageID = ageid, ageFraction = agefraction)
    
    # Filter by year
    data = data %>%
      filter(yearID == .year)
    
    
    # Tally up how many rows occur per sourceTypeID    
    tally = data %>%
      group_by(sourceTypeID) %>%
      count()
    
    # There should be this many...    
    tallynormal = tribble(
      ~sourceTypeID, ~n,
      11, 41,
      21, 41,
      31, 41,
      32, 41,
      41, 41,
      42, 41,
      43, 41,
      51, 41,
      52, 41,
      53, 41,
      54, 41,
      61, 41,
      62, 41
    )
    
    # Are these matrices entirely the same?
    is_same = all(tallynormal == tally)
    
    # If they are not, we will fill in the ageFraction for missing strata with DEFAULTS. 
    if(!is_same){
      # if not, need to grab default data 
      # Connect to database
      custom = connect("mariadb", .custom)
      # By default it is NOT empty
      fakedata = custom %>%
        tbl(table) %>%
        filter(yearID %in% !!.year)  %>%
        collect()
      # Disconnect
      dbDisconnect(custom)
      
      # Find all the strata that are MISSING in the observed data,
      # but are available in the default data.
      # Keep the observed ageFraction value
      extrarows = fakedata %>%
        select(sourceTypeID, yearID, ageID, ageFraction) %>% 
        distinct() %>%
        anti_join(
          by = c("sourceTypeID", "yearID", "ageID"),
          x = ., 
          y = data)
      
      # Bind in the extra rows
      data = bind_rows(
        data %>% mutate(group = "custom"), 
        extrarows %>% mutate(group = "default")) %>% 
        # Keep just distinct rows
        distinct()
      
      # For each sourcetype-year,
      # the extra rows constitute a certain percentage of the total size.
      myweights = data %>% 
        group_by(sourceTypeID, yearID) %>%
        summarize(weight = sum(group == "default") / sum(group == "default" | group == "custom"), 
                  .groups = "drop")

      
      # Suppose that you knew from defaults that 
      # age 40 - age 31 = 10% of all vehicles wof type X in year t
      # then age 0 - 30 = 90% of all vehicles of type X in year t
      # so if I have percentage for age o for all vehicles of type X in year t,
      # then I'll just weight it at 90%...
      
      # so that...
      # sourcetype 11 age 0 = 2% * 90%
      # sourcetype 11 age 1 = 1% * 90%
      # sourcetype 11 age 2 = 3% * 90%
      # ...
      # sourcetype 11 age 31 = 1% 
      # sourcetype 11 age 32 = 2%
      # should sum up to 1 at the end.
      
      # Join in the weights
      data = data %>%
        left_join(by = c("sourceTypeID", "yearID"),
                  y = myweights) %>%
        # Weight the ageFraction
        # so that we downweight any custom input data cases 
        # to make room for the proportional share of data represented by the defaults
        mutate(ageFraction = ageFraction * (1 - weight))  %>%
        # Drop the weight at the end
        select(-weight, -group)
      
      # Remember that you will need to re-normalize the ageFraction
      # so that it adds up to 1 for each sourcetype-year
      data = data %>%
        group_by(sourceTypeID, yearID) %>%
        mutate(ageFraction = ageFraction / sum(ageFraction, na.rm = TRUE)) %>%
        ungroup()
      
      cat("\n---sourcetypeagedistribution: some ages missing; inputed using national default ageFractions for those ages and renormalized.\n")
      
    }
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # must not filter by roadtype here
    # Query
    data = custom %>% tbl(table) %>% 
      filter(yearID %in% !!.year) %>%
      collect()
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}

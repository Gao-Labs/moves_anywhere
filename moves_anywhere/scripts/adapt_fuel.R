adapt_fuelsupply = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "fuelsupply"
  BUCKET = "inputs"
  
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  .year = rs$year
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  # Check also if fuelsupply is provided.
  f2 = get_is_custom(files, table = "fuelformulation")

  # If BOTH fuelsupply and fuelformulation are provided, use and filter that
  if(f$is_custom & f2$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$fuelsupply %>% names()
    # Select final columns
    data = data %>% 
      select(
        fuelRegionID = fuelregionid,
        fuelYearID = fuelyearid,
        monthGroupID = monthgroupid,
        fuelFormulationID = fuelformulationid,
        marketShare = marketshare,
        marketShareCV = marketsharecv
      )
    
    
    # Import the table
    import_table(data = data, tablename = table, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If either only fuelsupply or fuelformulation or neither are provided
    # we must estimate a default from past work.
  }else{
    cat("\n---estimating defaults for fuelsupply---\n")
    # Get fuelregion of this county    
    db = connect("mariadb", .custom)
    q1 = db %>%
      tbl("regioncounty") %>%
      filter(countyID == !!.geoid, fuelYearID %in% !!.year) %>%
      select(regionID, fuelYearID) %>%
      distinct() %>%
      collect()
    dbDisconnect(db)
    
    # Import defaults from NYC metro counties, available via PPS.
    data = readr::read_csv("scripts/fuelsupply.csv", show_col_types = FALSE) %>%
      # Overwrite the fuelYearID with this one.
      mutate(fuelYearID = .year) %>%
      # Overwrite the fuelRegionID with this one.
      mutate(fuelRegionID = q1$regionID[1])

    # For fuelsupply, marketShare MUST sum to 1 for each fueltype for each month
    # It is discouraged to update fuelsupply unless you know what you are doing.
    # # Connect to database
    # custom = connect("mariadb", .custom)
    # 
    # # Get the fuelregion ID for that county and year
    # q1 = custom %>% 
    #   tbl("regioncounty") %>%
    #   filter(countyID == !!.geoid, fuelYearID %in% !!.year) %>%
    #   select(regionID, fuelYearID) %>%
    #   distinct()
    # 
    # # Now get the fuelsupply table for that fuelregion and year
    # data = custom %>% 
    #   tbl("fuelsupply") %>%
    #   inner_join(by = c("fuelYearID", "fuelRegionID" = "regionID"), y = q1) %>%
    #   arrange(fuelRegionID, fuelYearID, monthGroupID, fuelFormulationID)  %>%
    #   collect()
    # 
    # # If fuelsupply is missing these fuelformulations, add them
    # if(any(data$fuelFormulationID %in% c(10,20,30,50,90))){
    #   
    #   # For each if missing
    #   for(i in c(10,20,30,50,90)){
    #     # If missing
    #     if(!i %in% data$fuelFormulationID ){
    #       # Create a set of rows to add...
    #       extra = tibble(
    #         fuelRegionID = data$fuelRegionID[1],
    #         fuelYearID = data$fuelYearID[1],
    #         monthGroupID = 1:12,
    #         fuelFormulationID = i,
    #         marketShare = 1, 
    #         marketShareCV = 0.5
    #       )
    #       # Append it atop 
    #       data = bind_rows(extra, data)
    #     }
    #   }
    # }
    # 
    data = data %>% 
      arrange(fuelRegionID, fuelYearID, monthGroupID, fuelFormulationID)
    
      
    # Query
    # data = custom %>% tbl("fuelsupply")  %>%
    #   # filter(fuelYearID %in% !!.year) %>%
    #   collect()
    # filter(
    #   fuelRegionID %in% !!ids$regionID,
    #   fuelYearID %in% !!.year,
    #   monthGroupID %in% !!.month)  %>%
    # filter(fuelFormulationID %in% c(2675, 2676)) %>%
    # left_join(
    #   by = c("fuelFormulationID"),
    #   y = custom %>%
    #     tbl("fuelformulation") %>%
    #     select(fuelFormulationID, fuelSubtypeID)
    # ) %>%
    # left_join(
    #   by = c("fuelSubtypeID"),
    #   y = custom %>%
    #     tbl("fuelsubtype") %>%
    #     select(fuelSubtypeID, fuelTypeID)
    # ) %>%
    # # For each fueltype...
    # # Rescale the marketShare of each fuelFormulation,
    # # in case they don't sum to 1,
    # # so that they do sum to 1.
    # group_by(fuelRegionID, fuelYearID, monthGroupID, fuelTypeID) %>%
    # mutate(marketShare = marketShare / sum(marketShare, na.rm = TRUE)) %>%
    # ungroup()  %>%
    # # Rescaling can produce divide by zero errors. We will replace these na values with 0.
    # mutate(marketShare = if_else(is.na(marketShare), true = 0, false = marketShare)) %>%
    # select(-any_of(c("fuelSubtypeID", "fuelTypeID"))) %>%
    # collect()
    
    # Disconnect
    # dbDisconnect(custom)
    
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}

adapt_fuelformulation = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){

  table = "fuelformulation"
  BUCKET = "inputs"
  
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  # Get name of custom input database
  .custom = rs$defaultdbname
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  .year = rs$year
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # Classify that table as valid or not
  f = get_is_custom(files, table = table)   
  
  # Check also if fuelsupply is provided.
  f2 = get_is_custom(files, table = "fuelsupply")
  
  
  # If BOTH fuelsupply AND fuelformulation are provided, use and filter that
  if(f$is_custom & f2$is_custom){
    
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # translators::inputs$fuelformulation %>% names()
    # Select final columns
    data = data %>% 
      select(
        fuelFormulationID = fuelformulationid,
        fuelSubtypeID = fuelsubtypeid,
        RVP = rvp,
        sulfurLevel = sulfurlevel,
        ETOHVolume = etohvolume,
        MTBEVolume = mtbevolume,
        ETBEVolume = etbevolume,
        TAMEVolume = tamevolume,
        aromaticContent = aromaticcontent,
        olefinContent = olefincontent,
        benzeneContent = benzenecontent,
        e200 = e200,
        e300 = e300,
        BioDieselEsterVolume = biodieselestervolume,
        CetaneIndex = cetaneindex,
        PAHContent = pahcontent,
        T50 = t50,
        T90 = t90)

    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If EITHER fuel supply or fuelformulation or NEITHER are provided, 
    # then we must rely on some defaults.
  }else{

    cat("\n---estimating defaults for fuelformulation---\n")

    
        
    # db = connect("mariadb", .custom)
    # 
    # 
    # q1 = db %>% 
    #   tbl("regioncounty") %>%
    #   filter(countyID == !!.geoid, fuelYearID %in% !!.year) %>%
    #   select(regionID, fuelYearID) %>%
    #   distinct()
    # 
    # # Now get the fuelsupply table for that fuelregion and year
    # q2 = db %>% 
    #   tbl("fuelsupply") %>%
    #   inner_join(by = c("fuelYearID", "fuelRegionID" = "regionID"), y = q1) %>%
    #   # and return the distinct fuel formulations for it
    #   select(fuelFormulationID) %>%
    #   distinct()
    # 
    # data = db %>% tbl("fuelformulation") %>% 
    #   # Narrow into just the fuel formulations described by the fuelsupply table
    #   inner_join(by = c("fuelFormulationID"),
    #              y = q2) %>%
    #   arrange(fuelFormulationID, fuelSubtypeID) %>%
    #   collect()
    # 
    # # Check and see if the main fuelsubtypes are accounted for.
    # if(any(!data$fuelSubtypeID %in% c(10,20,30,51,90)) ){
    #   # If any are not, import this file
    #   extra = readr::read_csv("scripts/helper_fuelformulation.csv", show_col_types = FALSE)
    #   
    #   # For each of these main fuel subtypes,
    #   for(i in c(10,20,30,51,90)){
    #     # If they are missing, ADD THEM from our default NY data.
    #     if(!any(data$fuelSubtypeID %in% i)){
    #       data = data %>% filter(fuelSubtypeID != i) %>% 
    #         bind_rows(extra %>% filter(fuelSubtypeID == i), .)
    #     }
    #     
    #   }
    #   
    # }
    # 
    # # Fill in any missing data with 0
    # data = data %>% 
    #   mutate(across(.cols = RVP:T90, .f = ~if_else(is.na(.x), true = 0, false = .x)))
    # 
    # dbDisconnect(db)
    
    # Import default from NY metro area
    data = readr::read_csv("scripts/fuelformulation.csv", show_col_types = FALSE)
    
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
  }
  
  
  # If not provided, just use the built-in default; no need to change.
  
}







adapt_fuelusagefraction = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "fuelusagefraction"
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
    
    # translators::inputs$fuelsupply %>% names()
    # Select final columns
    data = data %>% 
      select(
        countyID = countyid,
        fuelYearID = fuelyearid,
        modelYearGroupID = modelyeargroupid,
        sourceBinFuelTypeID = sourcebinfueltypeid,
        fuelSupplyFuelTypeID = fuelsupplyfueltypeid,
        usageFraction = usagefraction
      )
    
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    
    # EPA MOVES 4.0 Training Slides
    # https://www.epa.gov/system/files/documents/2023-12/moves4-training-slides-2023-12.pdf
    # Fuels: Fuel Usage

    # Connect to database
    custom = connect("mariadb", .custom)
    
    data = custom %>% tbl("fuelusagefraction") %>%
      # filter(fuelYearID %in% !!.year) %>%
      filter(countyID %in% !!.geoid,
             fuelYearID  %in% !!.year) %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}
adapt_avft = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  
  table = "avft"
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
    
    # translators::inputs$avft %>% names()
    # Select final columns
    data = data %>% 
      select(sourceTypeID = sourcetypeid,
             modelYearID = modelyearid,
             fuelTypeID = fueltypeid,
             engTechID = engtechid,
             fuelEngFraction = fuelengfraction)
    
    # Tally up how many rows occur per sourceTypeID    
    tally = data %>%
      group_by(sourceTypeID) %>%
      count()
    
    # There should be this many...    
    tallynormal = tribble(
      ~sourceTypeID, ~n,
      11,            111,
      21,            444,
      31,            444,
      32,            444,
      41,            555,
      42,            555,
      43,            555,
      51,            555,
      52,            555,
      53,            555,
      54,            555,
      61,            555,
      62,            444
    )
    
    # Are these matrices entirely the same?
    is_same = all(tallynormal == tally)
    
    # If they are not, we will fill in the fuelEngFraction for missing strata with 0. 
    if(!is_same){
      # if not, need to grab default data and add 0s for missing values in custom data.
      # Connect to database
      custom = connect("mariadb", .custom)
      # By default it is NOT empty
      fakedata = custom %>%
        tbl("samplevehiclepopulation") %>%
        group_by(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
        summarize(fuelEngFraction = sum(stmyFraction, na.rm = TRUE), .groups = "drop") %>%
        ungroup()  %>%
        collect()
      # Disconnect
      dbDisconnect(custom)
      
      # Find all the strata that are MISSING in the observed data,
      # but are available in the default data.
      # Set them all to zero, and bind them in.
      extrarows = fakedata %>%
        select(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
        distinct() %>%
        anti_join(
          by = c("sourceTypeID", "modelYearID", "fuelTypeID", "engTechID"),
          y = data) %>%
        mutate(fuelEngFraction = 0)
      
      # Bind in the extra rows
      data = bind_rows(data, extrarows) %>% 
        # Keep just distinct rows
        distinct()
    }
    
    # Import the table
    # AND - in case the table was adjusted through this process too, just write it to file too.
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
    
    # If not provided, estimate a default
  }else if(!f$is_custom){
    
    # To make the default AVFT,
    # you would group by all of the ID columns except regulatory class,
    # and then rename the stmyFraction column to FuelEngFraction.
    # We could also store any default inputs we needed to make (such as AVFT)
    # of the default inputs in database form, do the imports with the csv provided,
    # then copy any leftover tables from the default database or our own,
    # and change any necessary ids
    
    # https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md#samplevehiclepopulation
    
    # Connect to database
    custom = connect("mariadb", .custom)
    
    # By default it is NOT empty
    data = custom %>%
      tbl("samplevehiclepopulation") %>%
      group_by(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
      summarize(fuelEngFraction = sum(stmyFraction, na.rm = TRUE), .groups = "drop") %>%
      ungroup()  %>%
      collect()
    
    # Disconnect
    dbDisconnect(custom)
    
    # Import table!
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    
    # Cleanup
    remove(data)
  }  
  
}
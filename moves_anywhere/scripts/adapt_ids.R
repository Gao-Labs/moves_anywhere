adapt_ids = function(.runspec = "EPA_MOVES_Model/rs_custom.xml"){
  # setwd("/cat")
  # .runspec = "EPA_MOVES_Model/rs_custom.xml"
  # Load packages
  # library(catr, warn.conflicts = FALSE,  quietly = TRUE)
  # library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  # library(RMariaDB, warn.conflicts = FALSE,  quietly = TRUE)
  # library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  # # Load functions
  # source("scripts/adapt_functions.R")


  # This function will adapt all of the identifier tables needed for your run.  
  BUCKET = "inputs"
  
  # Get your list of key values from your runspec
  rs = catr::translate_rs(.runspec = .runspec)
  
  # Get name of default input database
  .custom = rs$defaultdbname
  .year =  rs$year # eg. 1:12,
  .month = rs$month # eg. 1:12,
  .hour = rs$hour # eg. 1:24,
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>%
    mutate(hourday = paste0(hour, day)) %>% with(hourday)
  .geoid = rs$geoid
  .geoidchar = stringr::str_pad(.geoid, width = 5, side = "left", pad = "0")
  .pollutant = rs$pollutant # NULL,
  
  # Get files for my bucket
  files = get_changes(BUCKET)
  
  # # Classify that table as valid or not
  # f = get_is_custom(files, table = table)   
  
  # IDENTIFIERS ##########################
  # Connect to database
  custom = connect("mariadb", .custom)
  
  # Get metadata from a series of table
  ids_data = custom %>%
    tbl("county") %>%
    # filter(countyID %in% 36005) %>%
    filter(countyID %in% !!.geoid)  %>%
    select(countyID, countyTypeID, stateID) %>%
    head(1) %>%
    mutate(year = !!.year) %>%
    left_join(
      by = "stateID", 
      y = custom %>% tbl("state") %>% 
        select(stateID, idleRegionID)) %>%
    left_join(
      by = "countyID", 
      y = custom %>% tbl("zone") %>% 
        select(countyID, zoneID)) %>%
    left_join(
      by = c("countyID", "year" = "fuelYearID"), 
      y= custom %>% tbl("regioncounty") %>% 
        select(countyID, fuelYearID, regionID)) %>%
    distinct() %>%
    left_join(
      by = "zoneID", 
      y = custom %>% tbl("zoneroadtype") %>% 
        select(zoneID, roadTypeID),
      multiple = "all") %>%
    collect() 
    
  # regionID - multiple per county
  # zoneID - 1 per county
  # idleregonID - 1 per county
  # custom %>% tbl("state") %>% select(stateID, idleRegionID) 
  

  # Reformat ids as a list object
  # ids = ids_data %>%
  #   select(c(countyID, countyTypeID, stateID, idleRegionID, zoneID, regionID)) %>%
  #   slice(1) %>%
  #   as.list()
  ids = ids_data %>% 
    select(
      any_of(c("countyID", "countyTypeID", "stateID", "idleRegionID", "zoneID"))
    ) %>%
    slice(1) %>%
    as.list()
  # Add in the unique region IDs
  ids$regionID = unique(ids_data$regionID)
  # Add in the unique roadtype IDs
  ids$roadTypeID = unique(ids_data$roadTypeID)
  
  
  remove(ids_data)
  
  
  # Get the polutant process ids
  pol = custom %>% 
    tbl("pollutantprocessassoc") %>%
    filter(pollutantID %in% !!.pollutant) %>%
    select(pollutantID, polProcessID) %>%
    distinct() %>%
    left_join(
      by = "polProcessID", 
      y = custom %>% tbl("opmodepolprocassoc"),
      multiple = "all") %>%
    collect()
  
  # Add them to the ids
  ids$polProcessID = pol$polProcessID %>% unique()
  ids$opModeID = pol$opModeID %>% unique()
  
  remove(pol)
  
  # Disconnect
  dbDisconnect(custom)
  
  # We'll use this metadata to obtain the sections of tables we need
  # for completing our custom database with default data.
  
  ### year #########################################################
  # If DEFAULTS
  table = "year"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("year") %>%
      filter(yearID %in% !!.year) %>% 
      collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names("year")
    data = data %>% 
      select(
        "yearID" = "yearid",
        "isBaseYear" = "isbaseyear",
        "fuelYearID" = "fuelyearid"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
  
  ### county #######################################################
  table = "county"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("county") %>%  filter(countyID %in% !!.geoid) %>% collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names("county")
    data = data %>% 
      select(
        "countyID" = "countyid",
        "stateID" = "stateid",
        "countyName" = "countyname",
        "altitude" = "altitude",
        "GPAFract" = "gpafract",
        "barometricPressure" = "barometricpressure",
        "barometricPressureCV" = "barometricpressurecv",
        "countyTypeID" = "countytypeid",
        "msa" = "msa"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
  
  ### state #################################  
  table = "state"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("state") %>%
      # filter(stateID %in% !!ids$stateID) %>% 
      collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # get_names(table = "state")
    data = data %>% 
      select(
        "stateID" = "stateid",
        "stateName" = "statename",
        "stateAbbr" = "stateabbr",
        "idleRegionID" = "idleregionid"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
  ### idleregion ######################
  table = "idleregion"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("idleregion") %>%  filter(idleRegionID %in% !!ids$idleRegionID) %>% collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "idleregion")
    data = data %>% 
      select(
        "idleRegionID" = "idleregionid",
        "idleRegionDescription" = "idleregiondescription"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  

  
  ### zone ###############################
  table = "zone"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("zone") %>% filter(countyID %in% !!.geoid) %>% collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "zone")
    data = data %>% 
      select(
        "zoneID" = "zoneid",
        "countyID" = "countyid",
        "startAllocFactor" = "startallocfactor",
        "idleAllocFactor" = "idleallocfactor",
        "SHPAllocFactor" = "shpallocfactor"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
 
  
  ### zoneroadtype ###############################
  table = "zoneroadtype"
  if(!table %in% files$changed){
    custom = connect("mariadb", .custom)
    # Download and filter the table
    data = custom %>% tbl("zoneroadtype") %>% filter(zoneID %in% !!ids$zoneID) %>% collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # get_names(table = "zoneroadtype")
    data = data %>% 
      select(
        "zoneID" = "zoneid",
        "roadTypeID" = "roadtypeid",
        "SHOAllocFactor" = "shoallocfactor"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
  
  ### regioncounty ################################################
  # Shrink the list of fuelregions to just those that align with your geoid
  table = "regioncounty"
  if(!table %in% files$changed){
    # Download and filter the table
    custom = connect("mariadb", .custom)
    data = custom %>% tbl("regioncounty") %>% filter(countyID %in% !!.geoid, fuelYearID %in% !!.year) %>% collect()
    dbDisconnect(custom)
    # Import table!
    import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    
    # get_names(table = "regioncounty")
    
    data = data %>% 
      select(
        "regionID" = "regionid",
        "countyID" = "countyid",
        "regionCodeID" = "regioncodeid",
        "fuelYearID" = "fuelyearid"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
  ### pollutantprocessassoc #################################  
  table = "pollutantprocessassoc"
  if(!table %in% files$changed){
    # Tentatively, if default, just skip. Use the defaults, no filtering.
    # custom = connect("mariadb", .custom)
    # Query
    # data = custom %>% tbl("pollutantprocessassoc") %>% filter(pollutantID %in% !!.pollutant) %>% collect() 
    # dbDisconnect(custom)
    # Import table!
    # import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "pollutantprocessassoc")
    data = data %>% 
      select(
        "polProcessID" = "polprocessid",
        "processID" = "processid",
        "pollutantID" = "pollutantid",
        "isAffectedByExhaustIM" = "isaffectedbyexhaustim",
        "isAffectedByEvapIM" = "isaffectedbyevapim",
        "chainedto1" = "chainedto1",
        "chainedto2" = "chainedto2",
        "isAffectedByOnroad" = "isaffectedbyonroad",
        "isAffectedByNonroad" = "isaffectedbynonroad",
        "nrChainedTo1" = "nrchainedto1",
        "nrChainedTo2" = "nrchainedto2"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  ### opmodepolprocassoc ###################################
  table = "opmodepolprocassoc"
  if(!table %in% files$changed){
    # Tentatively, if default, just skip. Use the defaults, no filtering.
    # Connect
    # custom = connect("mariadb", .custom)
    # Query
    # data = custom %>% tbl("opmodepolprocassoc") %>% filter(polProcessID %in% !!ids$polProcessID) %>% collect() 
    # dbDisconnect(custom)
    # Import table!
    # import_table(data = data, tablename = table, .custom = .custom, adapt = TRUE, save = TRUE, volume = BUCKET)
    # IF CUSTOMIZED
  }else if(table %in% files$changed){
    # Classify that table as valid or not
    f = get_is_custom(files, table = table)
    # Load data from file
    data = get_data(changes = f$changes, .geoidchar = .geoidchar)
    # get_names(table = "opmodepolprocassoc")
    data = data %>% 
      select(
        "polProcessID" = "polprocessid",
        "opModeID" = "opmodeid"
      )
    # Import the table
    import_table(data = data, tablename = f$changed, .custom = .custom, adapt = FALSE, save = TRUE, volume = BUCKET)
  }
  
  
}

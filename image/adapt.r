#' @name adapt
#' @title `adapt()` function - adapted for moves_anywhere
#' @author Tim Fraser
#' @description This function adapts existing default data to a new custom input database.
#' As opposed to past versions, we just literally edit the default database, rather than creating a separate database.
#' This is more efficient, since the default database is already built in the docker image and replicable with every new container.
#' 
#' @param .changes vector of file paths whose names match the table name they replace.
#' @param .runspec path to runspec
#' 
#' @importFrom dplyr `%>%` mutate filter tbl collect
#' @importFrom stringr str_remove str_extract
#' @importFrom readr read_csv
#' @importFrom tidyr expand_grid
#' @importFrom DBI dbWriteTable dbConnect dbDisconnect
#' 
#' @export

adapt = function(.runspec, .changes = NULL){
  
  # a script to 'adapt' existing default data to a new 'custom' db
  
  # Testing values:
  # .changes = NULL
  # .runspec = "inputs/rs_36109_2020_rs_moves31_custom_1.xml"
  # .runspec = "EPA_MOVES_Model/rs_custom.xml"
  # 1. RUNSPEC ###################################################
  
  # Load translate_rs() function
  
  # Save list of key values as object 'rs'
  rs = catr::translate_rs(.runspec = .runspec)
  
  # Relabel key values from runspec.
  .year = rs$year # eg. 2020
  .geoid = rs$geoid %>% as.integer() # eg. 36109
  .pollutant = rs$pollutant # NULL,
  .month = rs$month # eg. 1:12,
  .hour = rs$hour # eg. 1:24, 
  .day = rs$day  # eg. c(2,5)
  .hourday = tidyr::expand_grid(hour = .hour, day = .day) %>% 
    mutate(hourday = paste0(hour, day)) %>% with(hourday) 
  .custom = rs$inputdbname
  
  # .local = Sys.getenv("MDB_DEFAULT")
  .default = rs$default
  
  # If it's a default run, skip this whole thing.
  if(.default == TRUE){ 
    # Tell user we're not using custom inputs in this case
    cat("\n---default database selected. No custom input tables used.----\n")
    # End the function early
    return() 
  }
  
  
  # Write a short function to quickly connect
  custom = connect("mariadb", .custom)
  
  # 2. CHANGES #########################################################
  
  # If any changes supplied
  if(!is.null(.changes) & length(.changes) > 0){
    # For testing only
    # .changes = c("inputs/sourcetypeyear.csv", "inputs/startsperdaypervehicle.csv")
    # Get a list of table names that were changed (dropping the inputs/ and .csv parts)
    .changed = .changes %>% stringr::str_remove(".*[/]") %>% tolower() %>% stringr::str_remove("[.]csv")
    # Get a vector of filetypes 
    #.filetype = .changes %>% tolower() %>% stringr::str_extract("[.]csv")
    # Get an index vector
    .index = 1:length(.changed)
    # Get a list of tables
    tabs = custom %>% dbListTables()
    # For each custom input table provided
    for(i in .index){
      
      # If this table name a valid moves table, 
      # its template will be present in the default database
      # So let's check - is this table in the set of all moves default db tables, empty or not?
      if(.changed[i] %in% tabs){
        # Message
        cat(paste0("\n---", "importing custom table: ", .changed[i], "\n"))
        # Read in the file
        data = readr::read_csv(file = .changes[i])
        # If not empty
        if(nrow(data) > 0){
          # Truncate the table
          dbExecute(conn = custom, statement = paste0("TRUNCATE TABLE ", .changed[i], ";"))
          # Write it to the custom database with that table name. 
          # (Append, not overwrite - you truncated the table in the line before, and appending means you keep the existing column schema)
          DBI::dbWriteTable(conn = custom, name = .changed[i], value = data, overwrite = FALSE, append = TRUE)
        }
        # cleanup
        remove(data)
      }
    }
    
    # Otherwise, return the following blank vector
  }else{
    .changed = c()
  }
  
  
  # 3. DEFAULTS #############################################################################
  
  
  ## IDS ###########################################
  
  # Get metadata from a series of table
  ids_data = custom %>%
    tbl("county") %>%
    filter(countyID %in% !!.geoid)  %>%
    select(countyID, countyTypeID, stateID) %>%
    head(1) %>%
    mutate(year = !!.year) %>%
    left_join(by = "stateID", y = custom %>% tbl("state") %>% select(stateID, idleRegionID)) %>%
    left_join(by = "countyID", y = custom %>% tbl("zone") %>% select(countyID, zoneID)) %>%
    left_join(by = c("countyID", "year" = "fuelYearID"), 
              y= custom %>% tbl("regioncounty") %>% select(countyID, fuelYearID, regionID)) %>%
    distinct() %>%
    left_join(by = "zoneID", y= custom %>% tbl("zoneroadtype") %>% select(zoneID, roadTypeID)) %>%
    collect() 
  
  # Reformat ids as a list object
  ids = ids_data %>%
    select(c(countyID, countyTypeID, stateID, idleRegionID, zoneID, regionID)) %>%
    slice(1) %>%
    as.list()
  ids$roadTypeID = ids_data$roadTypeID
  remove(ids_data)
  
  # Get the polutant process ids
  pol = custom %>% 
    tbl("pollutantprocessassoc") %>%
    filter(pollutantID %in% !!.pollutant) %>%
    select(pollutantID, polProcessID) %>%
    distinct() %>%
    left_join(by = "polProcessID", y = custom %>% tbl("opmodepolprocassoc")) %>%
    collect()
  
  # Add them to the ids
  ids$polProcessID = pol$polProcessID %>% unique()
  ids$opModeID = pol$opModeID %>% unique()
  
  remove(pol)
  
  # We'll use this metadata to obtain the sections of tables we need
  # for completing our custom database with default data.
  
  ## IDENTIFIERS ##########################
  cat("\n\n---IDENTIFER TABLES----------------------\n")
  
  # Let's write a tiny function for summarizing our data tables
  counter = function(data){
    nums = dim(data)
    output = paste0(" [", nums[1], " x ", nums[2], "] ")
    return(output)
  }
  
  ### year #########################################################
  if(!"year" %in% .changed){
    # Download and filter the table
    data = custom %>% tbl("year") %>% filter(yearID %in% !!.year) %>% collect()
    # Truncate table, while preserving fiels
    DBI::dbExecute(custom, "TRUNCATE TABLE year;")
    # Append data back to table
    DBI::dbWriteTable(
      conn = custom, name = "year", value = data,
      #field.types = c("yearID" = "smallint(6)", "isBaseYear" = "char(1)", "fuelYearID" = "int(11)"),
      overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "year", counter(data)))
    # Cleanup
    remove(data)
  }
  ### county #######################################################
  if(!"county" %in% .changed){
    # Query data  
    data = custom %>% tbl("county") %>% filter(countyID %in% !!.geoid) %>% collect()
    # Truncate table, while preserving fiels
    DBI::dbExecute(custom, "TRUNCATE TABLE county;")
    # Append to table
    DBI::dbWriteTable(conn = custom, name = "county", value = data, overwrite = FALSE, append = TRUE)
    cat(paste0("\n---adapted default table:   ", "county", counter(data)))
    # Cleanup
    remove(data)
  }
  
  
  
  ### state #################################  
  if(!"state" %in% .changed){
    # Query
    data = custom %>%  tbl("state") %>% filter(stateID %in% !!ids$stateID) %>% collect()
    # Truncate table, while preserving fiels
    DBI::dbExecute(custom, "TRUNCATE TABLE state;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "state", value = data, overwrite = FALSE, append = TRUE)
    cat(paste0("\n---adapted default table:   ", "state", counter(data)))
    # Cleanup
    remove(data)
  }
  
  ### idleregion ######################
  if(!"idleregion" %in% .changed){
    # Query
    data = custom %>% tbl("idleregion") %>% filter(idleRegionID %in% !!ids$idleRegionID) %>% collect() 
    # Truncate table
    DBI::dbExecute(custom, "TRUNCATE TABLE idleregion;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "idleregion", value = data, overwrite = FALSE, append = TRUE)
    cat(paste0("\n\n---adapted default table:   ", "idleregion", counter(data)))
    # Cleanup
    remove(data)
  }
  
  ### totalidlefraction ######################  
  if(!"totalidlefraction" %in% .changed){
    # Query
    data = custom %>% tbl("totalidlefraction") %>%
      filter(idleRegionID %in% !!ids$idleRegionID, countyTypeID %in% !!ids$countyTypeID,
             monthID %in% !!.month, dayID %in% !!.day) %>% collect() 
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE totalidlefraction;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "totalidlefraction", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "totalidlefraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  ### imcoverage #################################
  if(!"imcoverage" %in% .changed){
    # Query
    data = custom %>% tbl("imcoverage") %>%
      filter(stateID %in% !!ids$stateID, countyID %in% !!.geoid, yearID %in% !!.year)  %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "imcoverage", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "imcoverage",counter(data)))
    # Cleanup
    remove(data)
    
  }
  ### zone ###############################
  if(!"zone" %in% .changed){
    # Query
    data = custom %>% tbl("zone") %>% 
      filter(countyID %in% !!.geoid) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE zone;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "zone", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "zone", counter(data)))
    # Cleanup
    remove(data)
  }
  ### zonemonthhour ################################
  if(!"zonemonthhour" %in% .changed){
    # Query
    data = custom %>% tbl("zonemonthhour") %>%
      filter(zoneID %in% !!ids$zoneID, monthID %in% !!.month, hourID %in% !!.hour) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE zonemonthhour;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "zonemonthhour", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "zonemonthhour", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ### zoneroadtype ###############################
  if(!"zoneroadtype" %in% .changed){
    # Query
    data = custom %>% tbl("zoneroadtype") %>% 
      filter(zoneID %in% !!ids$zoneID) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE zoneroadtype;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "zoneroadtype", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "zoneroadtype", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ## HOTELLING #################### 
  cat("\n\n---HOTELLING TABLES----------------------\n")
  
  ### hotellingactivitydistribution ###############################
  if(!"hotellingactivitydistribution" %in% .changed){
    # Query
    data = custom %>% tbl("hotellingactivitydistribution") %>% 
      filter(zoneID %in% !!ids$zoneID) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE hotellingactivitydistribution;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "hotellingactivitydistribution", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "hotellingactivitydistribution", counter(data)))
    # Cleanup
    remove(data)
  }
  
  ### (N/A) hotellinghoursperday #######################
  # .table = "hotellinghoursperday"
  # data = custom %>% tbl(.table) %>% collect()
  #    DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
  # DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  
  ### (N/A) hotellinghourfraction ##################
  # .table = "hotellinghourfraction"
  # data = custom %>% tbl(.table) %>% collect()
  #    DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
  #   DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  
  ### (N/A) hotellingagefraction ##################
  # .table = "hotellingagefraction"
  # data = custom %>% tbl(.table) %>% collect()
  #    DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
  #   DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  
  ### (N/A) hotellingmonthadjust #########################
  # .table = "hotellingmonthadjust"
  # data = custom %>% tbl(.table) %>% collect()
  #    DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
  #   DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  # https://www.epa.gov/sites/default/files/2021-05/documents/moves3-experienced-users-webinar-2021-05-05.pdf
  
  
  
  ## FUEL ########################################
  cat("\n\n---FUEL TABLES----------------------\n")
  # # Section 4.8.1 Fuel Formulation and Fuel Supply Guidance
  # # https://www.epa.gov/sites/default/files/2020-11/documents/420b20052.pdf
  # # Because fuel properties can be quite variable, EPA does not consider single or yearly
  # # station samples adequate for substitution
  # # In other words, just don't touch it, and take all the contents of the fuel supply table
  
  ### regioncounty ################################################
  # Shrink the list of fuelregions to just those that align with your geoid
  if(!"regioncounty" %in% .changed){
    # Query
    data = custom %>% tbl("regioncounty") %>% 
      filter(countyID %in% !!.geoid, fuelYearID %in% !!.year) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE regioncounty;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "regioncounty", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "regioncounty", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ### (N/A) fuelformulation #################################
  # .table = "fuelformulation"
  # data = custom %>% tbl(.table)  %>%
  #   collect()
  #   DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  
  ### fuelsupply #################################
  if(!"fuelsupply" %in% .changed){
    # Query
    data = custom %>% tbl("fuelsupply")  %>%
      filter(fuelRegionID %in% !!ids$regionID, fuelYearID %in% !!.year, monthGroupID %in% !!.month) %>%
      collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE fuelsupply;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "fuelsupply", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "fuelsupply", counter(data)))
    # Cleanup
    remove(data)
    
  }  
  ### fuelusagefraction #################################
  if(!"fuelusagefraction" %in% .changed){
    # Query
    data = custom %>% tbl("fuelusagefraction") %>%
      filter(countyID %in% !!.geoid, fuelYearID  %in% !!.year) %>% collect()
    # truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE fuelusagefraction;")
    # append
    DBI::dbWriteTable(conn = custom, name = "fuelusagefraction", value = data, overwrite = FALSE, append = TRUE)
    # message
    cat(paste0("\n---adapted default table:   ", "fuelusagefraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ### avft ####################################
  # If an avft table was not supplied by the user...
  if(!"avft" %in% .changed){
    # Estimate our own from the default database.
    
    
    # To make the default AVFT,
    # you would group by all of the ID columns except regulatory class, 
    # and then rename the stmyFraction column to FuelEngFraction. 
    # We could also store any default inputs we needed to make (such as AVFT) 
    # of the default inputs in database form, do the imports with the csv provided,
    # then copy any leftover tables from the default database or our own, 
    # and change any necessary ids
    
    # https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md#samplevehiclepopulation
    
    # Query
    data = custom %>%
      tbl("samplevehiclepopulation") %>%
      group_by(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
      summarize(fuelEngFraction = sum(stmyFraction, na.rm = TRUE), .groups = "drop") %>%
      ungroup()  %>%
      collect()
    # Truncate table, while preserving fields
    DBI::dbExecute(custom, "TRUNCATE TABLE avft;")
    # Append
    dbWriteTable(conn = custom, name = "avft", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "avft", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ## SOURCETYPE POPULATION #############################
  cat("\n\n---SOURCE TYPE POPULATION TABLES----------------------\n")
  
  ### sourcetypeyear #################################
  if(!"sourcetypeyear" %in% .changed){
    # Query the national level vehicle population by sourcetype,
    # which is recorded for the year 2020
    data = custom %>% tbl("sourcetypeyear") %>% collect()
    # By default, we're going to keep that same split of sourcetypes
    # but we're going to downweight each sourcetypepopulation
    # by the ratio of county population to national population
    # to guestimate what a true vehicle population might look like in that county
    # if the number of vehicles is related to population. (Which is often is, at least somewhat)
    
    # Example of Nation-Level default data
    # data = tribble(
    #   ~yearID, ~sourceTypeID, ~sourceTypePopulation,
    #   2023,    11,            1500000,
    #   2023,    21,            1700000,
    #   2023,    31,            2000000
    # )
    # .geoid = "36109"
    # .year = 2023
    
    # For geoid 36109
    estimates = catr::projections %>%
      filter(year == .year & geoid == .geoid)
    
    sourcetypeyear = data %>%
      # Reset the year to be whatever year our scenario is
      mutate(yearID = .year) %>%
      # Join in the population estimates for the scenario year
      left_join(by = c("yearID" = "year"), 
                y = estimates %>% select(year, fraction)) %>%
      # Weight the sourcetypepopulation by the county population vs. national population ratio
      mutate(sourceTypePopulation = sourceTypePopulation * fraction) %>%
      # Get required variables
      select(yearID, sourceTypeID, sourceTypePopulation)
    
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE sourcetypeyear;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "sourcetypeyear", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "sourcetypeyear", counter(data)))
    # Cleanup
    remove(data)
  }
  
  
  ## VEHICLE TYPE VMT #########################
  cat("\n\n---VEHICLE TYPE VMT TABLES----------------------\n")
  
  ### PICK ONE ######################################
  #### sourcetypedayvmt #################################
  #### hpmsvtypeday #################################
  #### sourcetypeyearvmt ################################
  #### hpmsvtypeyear #################################
  
  # Only one of these next 4 tables can be uploaded at one time.
  # Suppose this is our changed vector
  # .changed = c("sourcetypeyearvmt", "hpmsvtypeyear", "bird")
  
  # First, check if MULTIPLE TABLES are uploaded.
  items = c("sourcetypeyearvmt", "sourcetypedayvmt", "hpmsvtypeyear", "hpmsvtypeday")
  # Find me the items that meet our criteria and are in .changed  
  myitems = items[items %in% .changed]
  # How many were uploaded
  n_uploaded = sum(items %in% .changed)
  
  # If ZERO of these 4 tables are uploaded, draw THIS ONE TABLE FROM THE DEFAULTS.
  if(n_uploaded == 0){
    # Testing values
    # .year = 2023; .geoid = 36109
    # data = translators::inputs$hpmsvtypeyear
    
    # Query
    data = custom %>% tbl("hpmsvtypeyear") %>% collect()
    
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE hpmsvtypeyear;")
    
    
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
      filter(year == .year & geoid == .geoid)
    
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
   
    # Append
    DBI::dbWriteTable(conn = custom, name = "hpmsvtypeyear", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "hpmsvtypeyear", counter(data)))
    # Cleanup
    remove(data)
    
    # Truncate these alternatives - should be empty anyways, but can't run with more than 1 of these 4 tables
    DBI::dbExecute(custom, "TRUNCATE TABLE sourcetypedayvmt;")
    DBI::dbExecute(custom, "TRUNCATE TABLE sourcetypeyearvmt;")
    DBI::dbExecute(custom, "TRUNCATE TABLE hpmsvtypeday;")
    
    # If 1 is uploaded...
  }else if(n_uploaded == 1){
    # Then myitems has 1 item in it
    # myitems
    # Get the items that ARE NOT this.
    items_to_drop = items[!items %in% myitems]
    # For each item to drop, truncate that table
    if(length(items_to_drop) > 0){
      for(i in items_to_drop){ DBI::dbExecute(custom, statement = paste0("TRUNCATE TABLE ", i, ";")) }
    }
    
    # If MORE than 1 of these 4 are uploaded, 
  }else if(n_uploaded > 1){
    # Message
    cat(paste0("\n\n---WARNING: Multiple tables uploaded for section VEHICLE TYPE VMT when only 1 is allowed at a time. Overlapping tables: ", paste0(myitems, collapse = ", "), "\n"))
    cat("\nWill prioritize tables in this order: sourcetypedayvmt, hpmsvtypeday, sourcetypeyearvmt, hpmsvtypeyear\n")
    cat("\nIf this is a problem, remove the extra tables from inputs.\n\n")
    
    # We already uploaded the tables above, so we will DROP the less preferrable ones here.
    # IF "sourcetypedayvmt" is available...
    if("sourcetypedayvmt" %in% .changed){
      item_to_keep = "sourcetypedayvmt"
      # OTHERWISE, if "hpmsvtypeday" is available...
    }else if("hpmsvtypeday" %in% .changed){
      item_to_keep = "hpmsvtypeday"
      # OTHERWISE, if "sourcetypeyearvmt" is available...
    }else if("sourcetypeyearvmt" %in% .changed){
      item_to_keep = "sourcetypeyearvmt"
      # OTHERWISE, if "hpmsvtypeyear" is available...
    }else if("hpmsvtypeyear" %in% .changed){ 
      item_to_keep = "hpmsvtypeyear"
    }
    
    # Get the items that ARE NOT this.
    items_to_drop = items[!items %in% item_to_keep]
    # Drop these other items from the .changed vector
    .changed = .changed[!.changed %in% items_to_drop]
    # For each item to drop, truncate that table
    if(length(items_to_drop) > 0){
      for(i in items_to_drop){ DBI::dbExecute(custom, statement = paste0("TRUNCATE TABLE ", i, ";")) }
    }
    
  }
  
  
  
  
  ### ADDITIONAL TABLES ######################################
  
  #### dayvmtfraction #################################  
  if(!"dayvmtfraction" %in% .changed){ 
    # must not filter by roadtype here
    # Query
    data = custom %>% tbl("dayvmtfraction") %>% filter(monthID %in% !!.month & dayID %in% !!.day) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE dayvmtfraction;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "dayvmtfraction", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "dayvmtfraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  #### hourvmtfraction #################################  
  if(!"hourvmtfraction" %in% .changed){
    # Query
    data = custom %>% tbl("hourvmtfraction") %>% filter(dayID %in% !!.day, hourID %in% !!.hour) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE hourvmtfraction;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "hourvmtfraction", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "hourvmtfraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  #### monthvmtfraction #################################  
  if(!"monthvmtfraction" %in% .changed){
    # Query
    data = custom %>% tbl("monthvmtfraction") %>% filter(monthID %in% !!.month) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE monthvmtfraction;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "monthvmtfraction", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "monthvmtfraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ## AGE DISTRIBUTION ####################################
  cat("\n\n---AGE DISTRIBUTION TABLES----------------------\n")
  
  ### sourcetypeagedistribution #################################
  if(!"sourcetypeagedistribution" %in% .changed){
    # Query
    data = custom %>% tbl("sourcetypeagedistribution") %>% 
      filter(yearID %in% !!.year) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE sourcetypeagedistribution;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "sourcetypeagedistribution", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "sourcetypeagedistribution", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  
  
  
  ## STARTS ###############################################
  cat("\n\n---STARTS TABLES----------------------\n")
  
  ### startshourfraction #################################
  if(!"startshourfraction" %in% .changed){
    # Query
    data = custom %>% tbl("startshourfraction") %>% filter(dayID %in% !!.day, hourID %in% !!.hour) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE startshourfraction;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "startshourfraction", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "startshourfraction", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ### starts ###########################
  if(!"starts" %in% .changed){
    # Query
    data = custom %>% tbl("starts") %>% filter(yearID %in% !!.year) %>%  collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE starts;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "starts", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "starts", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  
  ### startsperday ###################
  if(!"startsperday" %in% .changed){
    # Query
    data = custom %>% tbl("startsperday") %>% filter(dayID %in% !!.day) %>%  collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE startsperday;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "startsperday", value = data, overwrite = FALSE, append = TRUE)
    # Mesage
    cat(paste0("\n---adapted default table:   ", "startsperday", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ### startsperdaypervehicle #################################  
  if(!"startsperdaypervehicle" %in% .changed){
    # Query
    data = custom %>% tbl("startsperdaypervehicle") %>% filter(dayID %in% !!.day) %>%  collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE startsperdaypervehicle;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "startsperdaypervehicle", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "startsperdaypervehicle", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ## AVG SPEED DISTRIBUTION #############################
  cat("\n\n---AVG SPEED DISTRIBUTION TABLES----------------------\n")
  
  ### avgspeeddistribution #################################  
  if(!"avgspeeddistribution" %in% .changed){ 
    # must not filter by roadtype here - to make sure that all roads are represented in calculations.
    # Query
    data = custom %>% tbl("avgspeeddistribution") %>% filter(hourDayID %in% !!.hourday) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE avgspeeddistribution;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "avgspeeddistribution", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "avgspeeddistribution", counter(data)))
    # Cleanup
    remove(data)
    
  }
  
  ## ROAD TYPE DISTRIBUTION ###########################################
  cat("\n\n---ROAD TYPE DISTRIBUTION TABLES----------------------\n")
  ### (N/A) roadtypedistribution #################################  
  # .table = "roadtypedistribution"
  # data = custom %>% tbl(.table) %>%
  #   # filter(roadTypeID %in% !!.roadtype) %>%
  #   collect()
  #   DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  # # 
  
  
  
  
  ## POLLUTANT #########################################################################
  cat("\n\n---POLLUTANT TABLES----------------------\n")
  
  
  ### pollutantprocessassoc #################################  
  if(!"pollutantprocessassoc" %in% .changed){
    # Query
    data = custom %>% tbl("pollutantprocessassoc") %>% filter(pollutantID %in% !!.pollutant) %>% collect() 
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE pollutantprocessassoc;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "pollutantprocessassoc", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "pollutantprocessassoc", counter(data)))
    # Clean
    remove(data)
    
  }
  
  ### opmodepolprocassoc #################################  
  if(!"opmodepolprocassoc" %in% .changed){
    # Query
    data = custom %>% tbl("opmodepolprocassoc") %>% filter(polProcessID %in% !!ids$polProcessID) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE opmodepolprocassoc;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "opmodepolprocassoc", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "opmodepolprocassoc", counter(data)))
    # Clean
    remove(data)
    
  }
  
  ### startsopmodedistribution #################################  
  if(!"startsopmodedistribution" %in% .changed){
    # Query
    data = custom %>% tbl("startsopmodedistribution") %>% 
      filter(opModeID %in% !!ids$opModeID, dayID %in% !!.day, hourID %in% !!.hour) %>% collect()
    # Truncate
    DBI::dbExecute(custom, "TRUNCATE TABLE startsopmodedistribution;")
    # Append
    DBI::dbWriteTable(conn = custom, name = "startsopmodedistribution", value = data, overwrite = FALSE, append = TRUE)
    # Message
    cat(paste0("\n---adapted default table:   ", "startsopmodedistribution", counter(data)))
    # Clean
    remove(data)
    
  }
  
  ## EXTRAS #################################
  # .vars = c("startsageadjustment", "startsmonthadjust",
  #           "idlemodelyeargrouping", "idlemonthadjust", "idledayadjust")
  # for(i in .vars){
  #   if(!i %in% .changed){
  #     data = custom %>% tbl(i) %>% collect()
  #           DBI::dbExecute(custom, "TRUNCATE TABLE imcoverage;")
  #      DBI::dbWriteTable(conn = custom, name = .table, value = data, overwrite = FALSE, append = TRUE)
  #   }
  # }
  
  
  
  # Connect to custom database
  # Get list of tables.
  # tabs = dbListTables(custom)
  
  # If missing, initialize these tables
  # Table descriptions from here:
  # https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/MOVESDatabaseTables.md
  
  # remove(tabs)
  
  # Z. DISCONNECT #####################################################
  # Always, always, always disconnect.
  DBI::dbDisconnect(custom); remove(custom) 
  #DBI::dbDisconnect(local); remove(local)
  gc()
  cat("\n---done!")
  
}

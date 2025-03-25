#' @name custom_rs
#' @title `custom_rs()` function
#' @description Designs a custom runspec file based off input parameters.
#' eg. custom_rs(.geoid = "36109", .year = 2020, .level = "county", .default = FALSE) 
#' 
#' # Frequently Customized Parameters
#' @param .geoid  (character) county/state FIPS code, eg. "36109"
#' @param .year  (integer) eg. 2020
#' @param .default  (logical) Is it a default run (`TRUE`) or a custom run (`FALSE`)? (eg. county-data-manager = custom). Default is `FALSE` (custom).
#' @param .path Output path for runspec.
#' @param .rate (logical) is this for emissions rate mode or inventory mode?
#' 
#' # Sensitive parameters - only change for a specific reason.
#' @param .pollutants (integer) Vector of integer `pollutantID`s. 
#' Will select all required pollutant-processes necessary to estimate that pollutant's emissions, using details from `get_polprocesses.R`
#' Default is CO2 Equivalent (`98`) plus Criterion Air Pollutants, namely:
#'  - Ozone = created when NOx (`3`) interacts with VOC (`87`)
#'  - Carbon Monoxide = `2`
#'  - Lead (measured by VOC) = `87`
#'  - Sulfur Dioxide (SO2) = `31`
#'  - Nitrogen Dioxide (NO2) = `33`
#'  - PM2.5 = `110`
#'  - PM10 = `100`
#'  Also...
#'  - PM10 - Brakewear `106`
#'  - PM10 - Tirewear `107`
#'  - PM2.5 - Brakewear `116`
#'  - PM2.5 - Tirewear `117`
#' @param .sourcetypes (integer) Vector of integer `sourceTypeID`s. Default is `NULL`, which grabs all of them. Suggested to use `NULL`, unless you really need to change it.
#' @param .fueltypes (integer) Vector of integer `fuelTypeID`s. Default is `NULL`, which grabs all of them. Suggested to use `NULL`, unless you really need to change it.
#' @param .roadtypes (integer) Vector of integer `roadTypeID`s. Default is `NULL`, which grabs all of them. Suggested to use `NULL`, unless you really need to change it.
#' 
#' Aggregation Settings
#' @param .level (character) level of MOVES run. Eg. "county". Should match `.geoid`. Defaults to `NULL`, in which case we programmatically identify the `"level"` from `.geoid` using `what_level()`. Better to be specific about your `.level` if you're not using county level.
#' @param .geoaggregation (character) Level of geo-aggregation of results. Options include `"county"`, `"state"`, `"link"`, `"nation"`. Typically should match up with your level, unless you have a specific reason for changing it. Default is `NULL`, where it just sets the supplied `.level` to be the `.geoaggregation` level.
#' @param .timeaggregation (character) Level of temporal-aggregation of results. Options include `"hour"`, `"day"`, `"month"`", `"year"`. Default is `"year"`.
#'
#' These parameters rarely change.
#' @param .normalize (logical) normalize the file path? FALSE
#' @param .id  description TBA. (ignore)
#' @param .outputdbname Output database name ("moves")
#' @param .outputservername Hostname of output database (defaults to "localhost")
#' @param .inputdbname Custom Input database name ("custom")
#' @param .inputservername Hostname of custom input database (defaults to "localhost") 
#' @param .defaultinputdbname Name of default input database. (should be default input database "movesdb20241112")
#' @param .defaultinputservername Hostname of default input datbase (defaults to "localhost")
#' @param .skipvalidation:logical Should we skip domain validation? TRUE or FALSE? Defaults to TRUE.
#' @importFrom xml2 read_xml as_list write_xml as_xml_document
#' @importFrom stringr str_sub
#' @importFrom dplyr `%>%`
#' @export

# Function to design a 'custom' runspec for 1 county for custom county data manager inputs
custom_rs = function(
    .geoid = "36109",
    .year = 2020,
    .default = FALSE,
    .path = "inputs/rs_custom.xml",
    .rate = FALSE,
    .pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107,116, 117),
    .sourcetypes = NULL,
    .fueltypes = NULL,
    .roadtypes = NULL,
    # Extra parameters
    .level = NULL,
    .geoaggregation = NULL,
    .timeaggregation = "year",
    # Rarely change    
    .normalize = FALSE,
    .id = 1,
    .outputdbname = "moves",
    .outputservername = "localhost",
    .inputdbname = "custom",
    .inputservername = "localhost",
    .defaultinputservername = "localhost",
    .defaultinputdbname =  "movesdb20241112",
    .skipvalidation = TRUE
){
  
  # Testing Values (comment out before pushing)  
  # .geoid = "36109";
  # .year = 2020;
  # .default = FALSE;
  # .path = "inputs/rs_custom.xml";
  # .rate = FALSE;
  # .pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107,116, 117);
  # .sourcetypes = NULL;
  # .fueltypes = NULL;
  # .roadtypes = NULL;
  # # Extra parameters
  # .level = NULL;
  # .geoaggregation = NULL;
  # .timeaggregation = "year";
  # # Rarely change
  # .normalize = FALSE;
  # .id = 1;
  # .outputdbname = "moves";
  # .outputservername = "localhost";
  # .inputdbname = "custom";
  # .inputservername = "localhost";
  # .defaultinputservername = "localhost";
  # .defaultinputdbname =  "movesdb20241112"
  # .skipvalidation = FALSE
  # require(xml2, warn.conflicts = FALSE)
  # require(dplyr, warn.conflicts = FALSE)
  # library(catr)
  # FUNCTIONS ########################################
  # Short function for turning words' first letter upper case
  uppercase = function(word){
      a =  toupper(stringr::str_sub(word, 1,1))
      b = stringr::str_sub(word, 2, -1)
      paste0(a,b)
  }
  
  
  # MODE ##############################################
  if(.rate == TRUE){
    # Get template runspec for a rate mode run
    data("rs_template_rate", envir = environment()); x = rs_template_rate; remove(rs_template_rate)
    # Set mode
    attr(x$runspec$modelscale, "value") = "Rates"
    
  }else if(.rate == FALSE){
    # Get template RS for an inventory mode run
    data("rs_template_inventory", envir=environment()); x = rs_template_inventory; remove(rs_template_inventory)
    # Set mode
    attr(x$runspec$modelscale, "value") = "Inv"
  }
  
  ## LEVEL ####################################
  # If .level is not provided, use `what_level()` function to find it.
  # See R/what_level.R
  if(is.null(.level)){ .level = what_level(.geoid) }
  
  # GENERAL CONDITIONS ###########################
  
  # Set general conditions, which may get overridden below
  # Format .geographic selection as "ZONE" "STATE" "COUNTY" etc.
  .geographicselection = toupper(.level)

  # Extract geographic attributes
  attr(x$runspec$geographicselections$geographicselection, "type") = .geographicselection
  attr(x$runspec$geographicselections$geographicselection, "key") <-  .geoid 
  attr(x$runspec$geographicselections$geographicselection, "description") <- ""
  # If not provided, make it aggregate to the level described. 
  # Otherwise, aggregate to whatever is requested
  # Format geographicoutputdetail as "LINK" "STATE" "COUNTY" "NATION" etc.
  if(is.null(.geoaggregation)){ .geographicoutputdetail = .geographicselection }else{ .geographicoutputdetail = toupper(.geoaggregation) }
  # Format time aggregation as "Year" "Hour" "Month" etc.
  .timeaggregation = uppercase(.timeaggregation)
  
  # DEFAULT? ################################
  # IF NOT A DEFAULT RUN, set these values...
  if(.default == FALSE){ 
    .domain = "SINGLE"; .name = "custom"; .description = "Temporary custom input database.";
    # But if it's a DEFAULT run, you'll need these settings.
  }else if(.default == TRUE){ 
    .domain = "DEFAULT"; .name = "default"; .inputdbname = ""; .inputservername = ""; .description = "";
  }

  ## OUTPUT DETAIL ###########################
  # Extract Geographic Output Detail Level
  attr(x$runspec$geographicoutputdetail, "description") = .geographicoutputdetail
  
  # TIME ##################################################
  
  ## Set year ################################################
  # Set year of interest
  attr(x$runspec$timespan$year, "key") = as.character(.year)

  ## AGGREGATION #############################################  
  # Update aggregation time category (eg. by "Year", by "Month", by "Hour", etc)  
  attr(x$runspec$timespan$aggregateBy, "key") = .timeaggregation

  # Time Units in Output (eg. "Year")
  attr(x$runspec$outputtimestep, "value") = .timeaggregation

  # Time Units in Output (eg. "Years") - Note: yes, it's plural  
  attr(x$runspec$outputfactors$timefactors, "units") = paste0(.timeaggregation, "s")

  
    
  # OUTPUT DATABASE ###############################################
  attr(x$runspec$outputdatabase, "databasename") <- .outputdbname
  attr(x$runspec$outputdatabase, "servername") <- .outputservername

  
  # SCALE INPUT DATABASE ################################################
  attr(x$runspec$scaleinputdatabase, "databasename") = .inputdbname
  attr(x$runspec$scaleinputdatabase, "servername") = .inputservername
  attr(x$runspec$scaleinputdatabase, "description") = .description

  # DEFAULT INPUT DATABASE ##########################################
  attr(x$runspec$inputdatabase, "databasename") = .defaultinputdbname
  attr(x$runspec$inputdatabase, "servername") = .defaultinputservername
  attr(x$runspec$inputdatabase, "description") = "defaults"
  
  
  # RUN TYPE ##################################################
  # SET RUN TYPE ("SINGLE" COUNTY vs. "DEFAULT")
  attr(x$runspec$modeldomain, "value") = .domain

  # DESCRIPTION ###############################################
  # Update the runspec description
  x$runspec$description[[1]] <- paste0(.level, .geoid, " MOVES run with ", .name, " inputs")
  
  # ROADTYPE SELECTIONS #######################################
  # see get_roadtypes.R for background
  x$runspec$roadtypes = get_roadtypes(.roadtypes = .roadtypes)
  
  # VEHICLE SELECTIONS ##################################################
  # see get_vehicleselections.R for background
  x$runspec$onroadvehicleselections = get_vehicleselections(.sourcetypes = .sourcetypes, .fueltypes = .fueltypes)
  
  # POLLUTANT ASSOCIATIONS #########################################
  # see get_pollutantprocessassoc.R for background
  x$runspec$pollutantprocessassociations = get_pollutantprocessassoc(.pollutants = .pollutants)

  # DOMAIN VALIDATION ############################################### 
  attr(x$runspec$skipdomaindatabasevalidation, "selected") = .skipvalidation
  
  
  # WRITE #####################################
  if(.normalize == TRUE){
    # Normalize the path 
    # (sometimes has issues, so default for `.normalize` is now FALSE)
    .path = normalizePath(.path, winslash = "/")
  }
  # Write as xml
  xml2::write_xml(x = xml2::as_xml_document(x), file = .path)
  
  # Print completion message
  print(paste0(.geoid, "-", .year, "-", .name, "--- done!"))
  
  
  return(.path)
  
}
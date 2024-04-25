#' @name custom_rs
#' @title `custom_rs()` function
#' @description Designs a custom runspec file based off input parameters.
#' eg. custom_rs(.geoid = "36109", .year = 2020, .level = "county", .default = FALSE) 
#' @param .geoid  description TBA.
#' @param .year  description TBA.
#' @param .level  description TBA.
#' @param .default  description TBA.
#' @param .id  description TBA.
#' @param .outputdbname Output database name
#' @param .outputservername Hostname of output database (defaults to localhost)
#' @param .inputdbname Custom Input database name
#' @param .inputservername Hostname of custom input database (defaults to localhost) 
#' @param .path Output path for runspec.
#' @param .normalize (logical) normalize the file path? FALSE
#' @param .rate (logical) is this for emissions rate mode or inventory mode?
#' @importFrom xml2 read_xml as_list write_xml as_xml_document
#' @importFrom stringr str_sub
#' @export

# Function to design a 'custom' runspec for 1 county for custom county data manager inputs
custom_rs = function(
    .geoid = "36109",
    .year = 2020,
    .level = "county",
    .default = FALSE,
    .id = 1,
    .outputdbname = "moves",
    .outputservername = "localhost",
    .inputdbname = "movesdb20240104",
    .inputservername = "localhost",
    .path = "inputs/rs_custom.xml",
    .normalize = FALSE,
    .rate = FALSE,
    # Extra parameters
    .geoaggregation = NULL,
    .timeaggregation = "year"
    # .timeaggregation = "year",
    # .timefactors = "year"
){
  
  # Testing Values (comment out before pushing)  
  # .geoid = "36109"
  # .year = 2020
  # .level = "county"
  # .default = FALSE
  # .id = 1
  # .outputdbname = "moves"
  # .outputservername = "localhost"
  # .inputdbname = "movesdb20240104"
  # .inputservername = "localhost"
  # .path = "inputs/rs_custom.xml"
  # require(xml2, warn.conflicts = FALSE)
  # require(dplyr, warn.conflicts = FALSE)
  
  # FUNCTIONS ########################################
  # Short function for turning words' first letter upper case
  uppercase = function(word){
      a =  toupper(stringr::str_sub(word, 1,1))
      b = stringr::str_sub(word, 2, -1)
      paste0(a,b)
  }
  
  # GENERAL CONDITIONS ###########################
  # Set general conditions, which may get overridden below
  # Format .geographic selection as "ZONE" "STATE" "COUNTY" etc.
  .geographicselection = toupper(.level)
  # If not provided, make it aggregate to the level described. Otherwise, aggregate to whatever is requested
  # Format geographicoutputdetail as "LINK" "STATE" "COUNTY" "NATION" etc.
  if(is.null(.geoaggregation)){ .geographicoutputdetail = .level }else{ .geographicoutputdetail = toupper(.geoaggregation) }
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
  
  # MODE ##############################################
  if(.rate == TRUE){
    # Get template runspec for a rate mode run
    data("rs_template_rate", envir = environment()); x = rs_template_rate; remove(rs_template_rate)
    # Set mode
    x$runspec$modelscale |> attr("value") = "Rates"
    # Q1 ########################################
    # - geographicoutputdetail: does it have to be LINK for rate mode? Let's find out.
    # .geographicoutputdetail = if(.level == "county"){ "LINK" }
    # Q2 ###########################################
    # - Q2. outputtimestep: does it have to be "Hour" for rate mode?
    # .outputtimestep = "hour"
    # .timefactors = "hour"
    
  }else if(.rate == FALSE){
    # Get template RS for an inventory mode run
    data("rs_template", envir=environment()); x = rs_template; remove(rs_template)
    # Set mode
    attr(x$runspec$modelscale, "value") = "Inv"
  }
  

  
  # Qs ####################################################
  # - Q1. geographicoutputdetail: does it have to be LINK for rate mode? Let's find out.
  # - Q2. outputtimestep: does it have to be "Hour" for rate mode?
  # - Q3. outputfactors\timefactors --> Hours for rate mode?
  
  
  
  # GEOGRAPHY ###############################
  
  ## LEVEL ####################################
  # Extract geographic attributes
  #.g = x$runspec$geographicselections$geographicselection
  x$runspec$geographicselections$geographicselection |> attr("type") = .geographicselection
  x$runspec$geographicselections$geographicselection |> attr("key") <-  .geoid 
  x$runspec$geographicselections$geographicselection |> attr("description") <- ""
  # Update the actual runspec again.
  # x$runspec$geographicselections$geographicselection <- .g
  # remove(.g)
  
  ## OUTPUT DETAIL ###########################
  # Extract Geographic Output Detail Level
  attr(x$runspec$geographicoutputdetail, "description") = .geographicoutputdetail
  
  # TIME ##################################################
  
  ## Set year ################################################
  # Set year of interest
  attr(x$runspec$timespan$year, "key") = as.character(.year)

  ## AGGREGATION #############################################  
  # Update aggregation time category (eg. by "Year", by "Month", by "Hour", etc)  
  x$runspec$timespan$aggregateBy |> attr("key") = .timeaggregation

  # Time Units in Output (eg. "Year")
  x$runspec$outputtimestep |> attr("value") = .timeaggregation

  # Time Units in Output (eg. "Year")  
  x$runspec$outputfactors$timefactors |> attr("units") = .timeaggregation

  
    
  # OUTPUT DATABASE ###############################################
  x$runspec$outputdatabase |> attr( "databasename") <- .outputdbname
  x$runspec$outputdatabase |> attr("servername") <- .outputservername

  
  # INPUT DATABASE ################################################
  x$runspec$scaleinputdatabase |> attr("databasename") = .inputdbname
  x$runspec$scaleinputdatabase |> attr("servername") = .inputservername
  x$runspec$scaleinputdatabase |> attr( "description") = .description

  # RUN TYPE ##################################################
  # SET RUN TYPE ("SINGLE" COUNTY vs. "DEFAULT")
  x$runspec$modeldomain |> attr("value") = .domain

  # DESCRIPTION ###############################################
  # Update the runspec description
  x$runspec$description[[1]] <- paste0(.level, .geoid, " MOVES run with ", .name, " inputs")
  
  # Design the filepath (outddated - let's just use rs_custom.xml)
  # .path = paste0(.dir, "/", "rs", "_", .geoid, "_", .year, "_rs_moves31_", .name, "_", .id, ".xml")
  
  if(.normalize == TRUE){
    # Normalize the path
    .path = normalizePath(.path, winslash = "/")
  }
  # Write as xml
  xml2::write_xml(x = xml2::as_xml_document(x), file = .path)
  
  # Print completion message
  print(paste0(.geoid, "-", .year, "-", .name, "--- done!"))
  
  
  return(.path)
  
}
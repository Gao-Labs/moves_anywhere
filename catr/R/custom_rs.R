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
#' @importFrom xml2 read_xml as_list write_xml as_xml_document
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
    .path = "inputs/rs_custom.xml"
){

  # Testing Values (comment out before pushing)  
  .geoid = "36109"
  .year = 2020
  .level = "county"
  .default = FALSE
  .id = 1
  .outputdbname = "moves"
  .outputservername = "localhost"
  .inputdbname = "movesdb20240104"
  .inputservername = "localhost"
  .path = "inputs/rs_custom.xml"
  # require(xml2, warn.conflicts = FALSE)
  # require(dplyr, warn.conflicts = FALSE)


  # load("catr/data/rs_template.rda")
  # Set database information  
  
  # Set rs_folder to TEMP_FOLDER by default.
  # if(is.null(.dir)){ .dir = Sys.getenv("TEMP_FOLDER") }

  
  # Get template RS
  data("rs_template", envir=environment()); x = rs_template; remove(rs_template)
  #x = helper("rs_template")
  
  # GEOGRAPHY ###############################
  # Extract geographic attributes
  .g = x$runspec$geographicselections$geographicselection
  attr(.g, "type") <- toupper(.level)
  attr(.g, "key") <-  .geoid 
  attr(.g, "description") <- ""
  # Update the actual runspec again.
  x$runspec$geographicselections$geographicselection <- .g
  remove(.g)
  
  # Extract Geographic Output Detail Level
  .g <- x$runspec$geographicoutputdetail
  attr(.g, "description") <- toupper(.level)
  x$runspec$geographicoutputdetail <- .g
  remove(.g)
  

  # IF NOT A DEFAULT RUN, set these values...
  if(.default == FALSE){ 
    .domain = "SINGLE";
    .description = "Temporary custom input database for cat_inputter";
    .name = "custom"
    # But if it's a DEFAULT run, you'll need these settings.
  }else if(.default == TRUE){ 
    .domain = "DEFAULT"; .inputdbname = ""; .inputservername = ""; .description = ""; .name = "default"
  }
  
  # OUTPUT DATABASE ###############################################
  .o <- x$runspec$outputdatabase   # Extract output database attributes
  attr(.o, "databasename") <- .outputdbname
  attr(.o, "servername") <- .outputservername
  x$runspec$outputdatabase <- .o # # Update actual runspec
  remove(.o)
  
  # INPUT DATABASE ################################################
  .o = x$runspec$scaleinputdatabase
  attr(.o, "databasename") = .inputdbname
  attr(.o, "servername") = .inputservername
  attr(.o, "description") = .description
  x$runspec$scaleinputdatabase <- .o; remove(.o)
  
  # SET RUN TYPE ("SINGLE" COUNTY vs. "DEFAULT")
  .o = x$runspec$modeldomain
  attr(.o, "value") = .domain
  x$runspec$modeldomain = .o; remove(.o)
  
  .t = x$runspec$timespan$year
  attr(.t, "key") = as.character(.year)
  x$runspec$timespan$year = .t; remove(.t)
  
  # Update the runspec description
  x$runspec$description[[1]] <- paste0(.level, .geoid, " MOVES run with ", .name, " inputs")
  
  # Design the filepath (outddated - let's just use rs_custom.xml)
  # .path = paste0(.dir, "/", "rs", "_", .geoid, "_", .year, "_rs_moves31_", .name, "_", .id, ".xml")
  
  # Normalize the path
  .path = normalizePath(.path, winslash = "/")
  
  xml2::write_xml(x = xml2::as_xml_document(x), file = .path)

  print(paste0(.geoid, "-", .year, "-", .name, "--- done!"))
 
  
  return(.path)
  
}
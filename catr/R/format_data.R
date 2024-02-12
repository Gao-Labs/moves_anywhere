#' @name format_data
#' @title `format_data()`
#' @author Tim Fraser
#'
#' @description
#' Format MOVES output data into CAT data. 
#' @param .outputdbname Name of output database. Assumes host is localhost.
#' @param .run   # Specific MOVESRunID? (eg. 1)? If not, leave NULL.
#'
#' @param .level eg. "state"
#' @param .geoid eg. "17" (Illinois)
#' @param .by integer vector describing level of aggregation (eg. `8` = by sourcetype)
#' @param .pollutant Specific Pollutant (eg. 98)? If not, leave  NULL.
#' 
#' @param .path character stringr showing path to save output. Defaults to NULL and self generates.
#'
#' @importFrom stringr str_replace_all
#' @importFrom DBI dbConnect dbDisconnect
#' @importFrom purrr map_dfr
#'
#' @export

format_data = function(
  .outputdbname = "moves", .run = NULL, .path = NULL,
  .level = "state", .geoid = "17", .by = c(16, 8, 12, 14, 15), .pollutant = NULL){
  
  # If missing a temporary folder, make one here.
  if(is.null(.path)){
    # Get a temporary file path
    .path = tempfile(tmpdir = Sys.getenv("TEMP_FOLDER"), fileext = ".rds")  
    # Fix the backslashes
    .path = stringr::str_replace_all(.path, "[/]|\\\\", replacement = "//")
  }
  
  # Connect to output database #################################
  con = connect(type = "mariadb", .outputdbname)
  
  # Requirements
  if(is.null(.geoid) | is.null(.level)){ print("Stopping: .geoid and .level both required."); stop() }
  if(is.null(con)){ print("Stopping: Local MariaDB connection must be specified in `.type` and name."); stop()   }
  if(.level == "county"){ print("Assuming all values in .geoid are from the same state... Bad news if not...")}
  
  # For each 'by' field 
  # By default, run these 5 'by' fields
  # (16 = overall, 8 = sourcetype, 12 = regclass, 14 = fueltype, 15= roadtype)
  # Process data for each 'by' and the specific selected geoid, at the selected LEVEL
  output = purrr::map_dfr(
    .x = .by, 
    .f = ~process_by(
      con = con, .by = ., .pollutant = .pollutant, 
      .geoid = .geoid, .level = .level, .run = .run))
  
  # Disconnect from local database and remove irrelevant data
  DBI::dbDisconnect(con); remove(con)
  
  # Save data to file
  saveRDS(output, file = .path);
  
  # Print completion messages
  print("---processing: done"); print(paste("---path: ", .path))
  
  # Always return the file path, in case you want to check it with readr::read_rds()
  return(.path)
}

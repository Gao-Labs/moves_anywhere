#' @name format_moves
#' @title Format Data into CAT Format
#' @author Tim Fraser
#' 
#' @param path (character) path to .rds file containing table, on docker container
#' Advanced Parameters - only for use if you really need them. Otherwise, just change `inputs/parameters,json`
#' @param by (integer) vector of aggregation levels. Default is NULL, which defaults to levels specified in the `inputs/parameters.json`.
#' @param pollutant (integer) vector of pollutants to return. Default is NULL, which defaults to pollutants specified in the `inputs/paramters.json` 
#' @param path_parameters path to inputs/parameters.json file

#' @importFrom jsonlite fromJSON
#' 
#' @export
format_moves = function(path = "data.rds", by = NULL, pollutant = NULL, path_parameters = "inputs/parameters.json"){
  
  # Load packages
  # library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  # library(jsonlite, warn.conflicts = FALSE, quietly = TRUE)
  # library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  # library(RMariaDB, warn.conflicts = FALSE, quietly = TRUE)
  # library(catr, warn.conflicts = FALSE, quietly = TRUE)
  
  # Load connect() function
  # source("connect.r")
  
  # Re-import the parameters json file as 'p'
  p = jsonlite::fromJSON(path_parameters)
  
  # If nothing is supplied for by or pollutant, 
  # just fill with the original requests from the parameters.
  # This is meant to allow for more flexibility.
  if(is.null(pollutant)){ pollutant = p$pollutant  }
  if(is.null(by)){ by = p$by }
  
  # Manually set Enivironmental Variables using parameters file
  # (None of these are sensitive)
  
  # Sys.setenv(MDB_USERNAME=p$MDB_USERNAME)
  # Sys.setenv(MDB_PASSWORD=p$MDB_PASSWORD)
  # Sys.setenv(MDB_PORT=p$MDB_PORT)
  # Sys.setenv(MDB_HOST=p$MDB_HOST)
  # Sys.setenv(MDB_NAME=p$outputdbname)
  # Sys.setenv(MDB_DEFAULT=p$MDB_DEFAULT) # Update this with default db name
  # Sys.setenv(MOVES_FOLDER=p$MOVES_FOLDER) # Update this with path in container
  # Sys.setenv(TEMP_FOLDER=p$TEMP_FOLDER) # Update with the correct temp folder
  
  # Get most recent runID from moves output database
  # (Only relevant if multiple MOVES runs per outputdatabase, but it doesn't hurt)
  p$run = 1
  
  # db = connect(type = "mariadb", p$outputdbname)
  # # View tables
  # db %>% dbListTables()
  # dbDisconnect(db)
  
  # Format your data
  p$path = format_data(
    .outputdbname = Sys.getenv("OUTPUTDBNAME"), # output db to query
    .run = p$run, # runID (just one)
    .level = p$level, # level (just one)
    .geoid = p$geoid, # geoid (just one)
    .pollutant = pollutant, # pollutants (multiple)
    .by = by, # aggregation levels
    .path = path
  )
  
  # Print path to file
  cat(paste0("\n---data written to: ", p$path, "\n"))
  
  # Return the p object, if you need it.
  return(p$path)
}

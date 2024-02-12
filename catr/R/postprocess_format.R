#' @name postprocess_format.r
#' @title postprocessing code for formatting run AFTER invoking MOVES
#' @author Tim Fraser & colleagues
#' 
#' @param path_data path to output data file
#' @param csv (logical) Should it be outputted as a .csv or a .rds file? If TRUE, as a `.csv`. If FALSE, as a `.rds` file. Defaults to `.rds` for easy smaller storage.
#' Usually don't need to specify these
#' @param by (integer) Defaults to `NULL`. If `NULL`, uses the `by` values from the parameters.json supplied.
#' @param pollutant (integer) Defaults to `NULL`. If `NULL`, uses the `pollutant` values from the parameters.json supplied.
#' @param path_parameters path to inputs/parameters.json file
#' 
#' @importFrom stringr str_detect str_remove
#' @importFrom dplyr `%>%`
#' @importFrom readr read_rds write_csv
#'
#' @export 
postprocess_format = function(path_data = "data.rds", csv = FALSE, by = NULL, pollutant = NULL, path_parameters = "inputs/parameters.json"){
  # Testing values
  # path_parameters = "inputs/parameters.json"
  # path_data = "data.rds"
  # csv = FALSE

  
  # library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  # library(readr, warn.conflicts = FALSE, quietly = TRUE)
  # library(jsonlite, warn.conflicts = FALSE, quietly = TRUE)
  
  # Import parameters
  # p = jsonlite::fromJSON(path_parameters)
  
  # Load format_moves() function
  # source("format_moves.r")
  
  # Check if the output is a .rds file. If not, make it one.
  is_rds = stringr::str_detect(path_data, "[.]rds")
  # If it's not an rds file path, turn it into one
  if(is_rds){
    path_rds = path_data
  }else if(!is_rds){
    stem = stringr::str_remove(path_data, "[.]rds")
    path_rds = paste0(stem, '.rds')
  }
  
  # Format data and save to this path
  path = format_moves(path = path_rds, by = by, pollutant = pollutant, path_parameters = path_parameters)
  
  if(csv == FALSE){
    
    # Test like so
    # path %>% readr::read_rds() %>% head()
    
  # If they want it outputted as a .csv,
  }else if(csv == TRUE){
    # Remove the rds and add .csv
    path_csv = path_rds %>% stringr::str_remove("[.]rds") %>% paste0(., ".csv")
    
    # Take rds path
    path %>% 
      # Read in the file
      readr::read_rds() %>% 
      # Write it to csv
      readr::write_csv(path_csv)
    # Update path with the path_csv
    path = path_csv
    # Test like so
    # path %>% readr::read_csv() %>% head()
  }
  
  # Return the path
  return(path)
}

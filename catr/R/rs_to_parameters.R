#' @name rs_to_parameters
#' @title Make parameters from runspec
#' @author Tim Fraser
#' 
#' @param path_rs (character) path to runspec .xml file. Should be named `rs_custom.xml`, at whatever path needed.
#' @param path_parameters (character) path to parameters .json file. Should be named `parameters.json`, at whatever path needed.
#' @param tablename (character) eg. "d36109_u1_o1" name of Cloud SQL table to make.
#' Alternatively, you can provide the `user` id and `order` id instead and it will make a `tablename` for you.
#' @param user (integer) userid, eg. `1`
#' @param order (integer) orderid, eg. `2`
#' @param by (integer vector) aggregation type ids. Ranges from `1` to `16`. Defaults are `1`,`16`,`8`,`12`,`14`, and `15`.
#' @param return (logical) Return `p`, the parameters list? Default is `FALSE`.
#' 
#' @importFrom dplyr `%>%`
#' @importFrom jsonlite toJSON
#' @export
rs_to_parameters = function(path_rs = "rs_custom.xml", path_parameters = "parameters.json", tablename = NULL, user = 1, order = 1, by = c(1,16,8,12,14,15),  multiple = FALSE, return = FALSE){
  
  # Testing values
  # setwd(rstudioapi::getActiveProject())
  # setwd("catr")
  # path_rs = 'z/test.xml'
  
  p = path_rs %>%
    translate_rs() %>%
    # Extract a list of values
    with(list(
      geoid = geoid, level = level, pollutant = pollutant, year = year,
      default = default, 
      # Extra values
      mode = mode, geoaggregation = geoaggregation, timeaggregation = timeaggregation))
  
  # If dtablename is not provided
  if(is.null(tablename)){
    # Build the tablename out of user and order
    tablename = paste0("d", p$geoid, "_", "u", user, "_", "o", order)
  }
  # Assign tablename to be 'dtablename' in the list
  p$dtablename = tablename
  
  
  # Parse as integer (if they're not integer, will become NA)
  by = as.integer(by)
  check_by = is.integer(by)
  if(check_by == TRUE){
    p$by = by
    # Otherwise, flag an error
  }else{
    stop("`by` must be an integer vector, like c(1, 16)")
  }
  
  # If multiple = TRUE, this means it's a scenario, so add mulitple = TRUE
  if(multiple == TRUE){
    p$multiple = TRUE
  }
  
  p %>%
    toJSON(pretty = TRUE, auto_unbox = TRUE) %>%
    cat(file = path_parameters)  
  
  # If return is true, return the list
  if(return == TRUE){
    return(p)
  }
}




#' @name get_runid
#' @title `get_runid()` function
#' @description
#' Function to get the MOVESRunID for your most recent moves run.
#' @param n number of most recent runs to return data for. Default is 1. Max is 100.
#' @param id TRUE
#' @param outputdbname "moves"
#' 
#' @importFrom dplyr `%>%` collect summarize tbl filter
#' @importFrom DBI dbConnect dbDisconnect
#' 
#' @export

get_runid = function(n = 1, id = TRUE, outputdbname = "moves"){
  
  # Testing parameters
  #outputdbname = "moves";
  # n = 1;
  #id = TRUE;
  
  
  # Get the ID of the most recent moves run!
  local = connect(.type = "mariadb", outputdbname) 
  
  # Get your MOVES output database to return the last 100 runs.
  series = local %>% 
    dplyr::tbl("movesrun") %>%
    dplyr::summarize(last = max(MOVESRunID, na.rm = TRUE)) %>% 
    dplyr::collect() %>%
    with(last)
  
  # If you ask for multiple runs, use 'last' to search for them.
  if(n > 1){
    # Extract the last id
    last = series$last
    # Now get the first id; default to 1 if it goes negative
    first = last - n;  first = if(first < 1){ 1}else{first}
    # Make a vector spanning from the first to last id
    series = first:last
  }
  
  # Filter to that range of records and collect it.
  result = local %>%
    dplyr::tbl("movesrun") %>%
    dplyr::filter(MOVESRunID %in% !!series) %>%
    dplyr::collect()
  
  # Disconnect!
  DBI::dbDisconnect(local); remove(local)
  
  # If id == TRUE, only return the IDs. Otherwise, return the data.frame
  if(id == TRUE){ result = result$MOVESRunID }
  
  # Return the Run information 
  return(result)
}

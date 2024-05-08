
#' @name set_pp_attributes
#' @title Set Pollutant-Process Attributes in a Runspec as an `R` `list()` object
#' @author Tim Fraser
#' @description
#' Creates 1 list item with 4 attributes.
#' This will become 1 pollutant-process chunk in a Runspec file.
#' 
#' @param .pollutantID eg. 98
#' @param .pollutantName eg. CO2 Equivalent
#' @param .processID eg. 1
#' @param .processName eg. Running Exhaust
#' 
#' @export
set_pp_attributes = function(.pollutantID, .pollutantName, .processID, .processName){
  output = list()
  attr(output, "pollutantkey") = as.character(.pollutantID)
  attr(output, "pollutantname") = as.character(.pollutantName)
  attr(output, "processkey") = as.character(.processID)
  attr(output, "processname") = as.character(.processName)
  return(output)
}

#' @name get_pp_attributes
#' @title Get Pollutant-Process Attributes from a Runspec chunk, provided as a `R` `list()` object
#' @author Tim Fraser
#' @description
#' Convert to table from a list formatted as a pollutant-process chunk from a Runspec
#' 
#' @param .list list object, eg. produced by `set_pp_attributes()`
#' 
#' @export
get_pp_attributes = function(.list){
  data.frame(
    pollutantID = attr(.list, "pollutantkey"),
    pollutantName = attr(.list, "pollutantname"),
    processID = attr(.list, "processkey"),
    processName = attr(.list, "processname")
  )
}


#' @name pp_to_process
#' @title Pollutant-Process ID to Process ID
#' @author Tim Fraser
#' @description
#' Convert a `polProcessID` to just the `processID`
#' 
#' @param `.polProcessID` (integer/character) pollutant process id eg. 601
#' 
#' @importFrom stringr str_sub
#' @export
pp_to_process = function(.polProcessID){
  x = str_sub(.polProcessID, start = -2, end = -1);
  x = as.integer(x);
  return(x)
}

#' @name pp_to_pollutant
#' @title Pollutant-Process ID to Pollutant ID
#' @author Tim Fraser
#' @description
#' Convert a `polProcessID` to just the `pollutantID`
#' 
#' @param `.polProcessID` (integer/character) pollutant process id eg. 601
#' 
#' @importFrom stringr str_sub
#' @export
pp_to_pollutant = function(.polProcessID){
  x = str_sub(.polProcessID, start = 1, end = -3)
  x = as.integer(x)
  return(x)
}

#' @name get_pollutantprocessassoc
#' @title Function to create pollutant process association chunks in runspec.
#' @author Tim Fraser
#' @description
#' Vectorized function that returns a list of list objects
#' formatted to be pollutant-process association chunks in a Runspec. 
#' 
#' @param .pollutants (integer vector) Vector of `pollutantID`s. Should be formatted as integers. (They will be coerced to be integers.)
#' 
#' @importFrom dplyr `%>%` select mutate distinct left_join n filter
#' @importFrom purrr map
#' 
#' @export
get_pollutantprocessassoc = function(.pollutants){
  # Take .pollutants and make integer
  .pollutants = as.integer(.pollutants)
  # If any become NA after being forced to become integers, stop the process.
  if(any(is.na(.pollutants))){ stop("Some of your pollutantIDs are not integers. This doesn't seem quite right. Please revise.") }
  
  # Get all distinct pollutant-processes required to estimate 
  # those pollutant's emissions
  pp = catr::reqprocesses %>%
    filter(pollutantID %in% .pollutants) %>%
    # Get just the distinct pollutant-process ids
    select(polProcessID) %>%
    distinct()
  
  # Get number of vaild pollutant-process ids found
  n_pp = nrow(pp)  
  
  # If there are no pollutant-processes matching that pollutant
  if(n_pp == 0){
    stop(paste0(
      "The supplied pollutants IDs have no polllutant-processes available for estimation. ",
      "Review and edit your pollutants."))
    return(NULL)
  }else{
    pdata = pp %>%
      # Convert to pollutant ID and process ID
      mutate(
        # Convert pollutant-process ID to just pollutant ID
        pollutantID = pp_to_pollutant(.polProcessID = polProcessID),
        # Convert pollutant-process ID to just process ID
        processID = pp_to_process(.polProcessID = polProcessID)) %>% 
      # And join in the pollutant name and process names
      left_join(by = "processID",
                y = catr::tab_emissionprocess %>% select(processID, processName)) %>%
      left_join(by = "pollutantID",
                y = catr::tab_pollutant %>% select(pollutantID, pollutantName)) %>%
      mutate(row = 1:n())
    
    # Now convert each row into a separate runspec pollutant-process association chunk,
    # telling the runspec to make sure MOVES runs each.
    plist = pdata %>% 
      # Split into a list
      split(.$row) %>% 
      # For each item, set attributes
      purrr::map(~set_pp_attributes(.pollutantID = .$pollutantID, .pollutantName = .$pollutantID, 
                                    .processID = .$processID, .processName = .$processName)) %>% 
      # Set the name of each to be pollutant process association.
      setNames(., nm = rep("pollutantprocessassociation", length(.)) )
    
    return(plist)
  }
  
}
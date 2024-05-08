# catr::tab_onroadvehicleselections
# Testing values
# library(dplyr)
# library(purrr)

#' @name set_v_attributes
#' @title Set Onroad Vehicle Selection attributes in `R` `list()` format.
#' @author Tim Fraser
set_v_attributes = function(.fueltypeid, .fueltypedesc, .sourcetypeid, .sourcetypename){
  output = list()
  attr(output, "fueltypeid") = as.character(.fueltypeid)
  attr(output, "fueltypedesc") = as.character(.fueltypedesc)
  attr(output, "sourcetypeid") = as.character(.sourcetypeid)
  attr(output, "sourcetypename") = as.character(.sourcetypename)
  return(output)
}
#' @name get_v_attributes
#' @title Get Onroad Vehicle Selection attributes from a `R` `list()` as a table.
#' @author Tim Fraser
get_v_attributes = function(.list){
  data.frame(
    sourcetypeid = attr(.list, "sourcetypeid"),
    sourcetypename = attr(.list, "sourcetypename"),
    fueltypeid = attr(.list, "fueltypeid"),
    fueltypedesc = attr(.list, "fueltypedesc")
  )
}

#' @name get_vehicleselections
#' @title Get Onroad Vehicle Selections in bulk in Runspec format
#' @description
#' Depending on vehicles selected, gets **all** fueltypes available.
#' @author Tim Fraser
#' 
#' @param .sourcetypes (integer) integer vector of `sourceTypeID`s that you want to filter by. Leave blank (`NULL`) to use all. 
#' @param .fueltypes (integer) integer vector of `fuelTypeID`s that you want to filter by. Leave blank (`NULL`) to use all.
#'  
#' @importFrom dplyr `%>%` filter mutate
#' @importFrom purrr map
#' 
#' @examples
#' # All possible, valid sourcetype-fueltype combinations
#' get_vehicleselections()
#' 
#' # Electric passenger cars only
#' get_vehicleselections(.sourcetype = 21, .fueltype = 9)
#'
#' @export
get_vehicleselections = function(.sourcetypes = NULL, .fueltypes = NULL){
  # Testing values
  # .sourcetype = c(21, 31)
  vdata = catr::tab_onroadvehicleselections
  
  # If sourcetypes are provided...
  
  if(!is.null(.sourcetypes)){
    # If any of the sourcetypes provided are not valid integers
    if(any(is.na(as.integer(.sourcetypes)))){
      stop("sourcetypes provided are not valid integers.")
    }
    # Filter to just those sourcetypes
    vdata = vdata %>%
      filter(sourcetypeid %in% .sourcetypes)
  }
  
  # If fueltypes are provided...  
  if(!is.null(.fueltypes)){
    # If any of the fueltypes provided are not valid integers
    if(any(is.na(as.integer(.fueltypes)))){
      stop("fueltypes provided are not valid integers.")
    }
    # Filter to just those fueltypes
    vdata = vdata %>%
      filter(fueltypeid %in% .fueltypes)
  }
  
  # Check length
  n_obs = nrow(vdata)
  # If there are no valid sourcetype-fueltype sets left after filters, stop.
  if(n_obs == 0){
    stop("No valid onroad vehicle selections are possible based on those inputs. Please try again!")
    return(NULL)
  }
  # Transform these data.frame rows into Runspec chunks,
  # where each row is a <onroadvehicleselection> chunk.
  vlist = vdata %>%
    mutate(row = 1:n()) %>%
    split(.$row) %>%
    map(~set_v_attributes(.sourcetypeid = .$sourcetypeid, .sourcetypename = .$sourcetypename,
                          .fueltypeid = .$fueltypeid, .fueltypedesc = .$fueltypedesc)) %>%
    setNames(., nm = rep("onroadvehicleselection", length(.)))
  
  return(vlist)
  
}

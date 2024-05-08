# testing
# library(catr)
# library(dplyr)
# library(purrr)

#' @name set_r_attributes
#' @title Set Roadtype Attributes for a `<roadtype>` Runspec chunk.
set_r_attributes = function(.roadtypeid, .roadtypename, .modelcombination){
  output = list()
  attr(output, "roadtypeid") = as.character(.roadtypeid)
  attr(output, "roadtypename") = as.character(.roadtypename)
  attr(output, "modelCombination") = as.character(.modelcombination)
  return(output)
}

#' @name get_roadtypes
#' @title Get `<roadtypes>` Runspec chunk
#' @author Tim Fraser
#' 
#' @param .roadtypes (integer) Vector of integer `roadTypeID`s. Defaults to `NULL`, which selects all `roadTypeID`s. Recommended to use `NULL` unless you have a compelling reason.
#' 
#' @examples
#' get_roadtypes(.roadtypes = c(1, 2))
#' 
#' @importFrom dplyr `%>%` filter mutate
#' @importFrom purrr map
#' 
#' @export
get_roadtypes = function(.roadtypes = NULL){
  
  rdata = tab_roadtypes
  
  # If roadtypes are provided...  
  if(!is.null(.roadtypes)){
    # If any of the roadtypes provided are not valid integers
    if(any(is.na(as.integer(.roadtypes)))){
      stop("roadtypes provided are not valid integers.")
    }
    
    # Take .roadtypes and make integer
    .roadtypes = as.integer(.roadtypes)
  
      # Get relevant roadtypes
    rdata = rdata %>%
      filter(roadtypeid %in% .roadtypes)
  }
  
  # Check length
  n_obs = nrow(rdata)
  # If there are no valid sourcetype-fueltype sets left after filters, stop.
  if(n_obs == 0){
    stop("No valid roadtype selections are possible based on those inputs. Please try again!")
    return(NULL)
  }
  # Transform these data.frame rows into Runspec chunks,
  # where each row is a <roadtype> chunk.
  rlist = rdata %>%
    mutate(row = 1:n()) %>%
    split(.$row) %>%
    map(~set_r_attributes(.roadtypename = .$roadtypename,
                          .roadtypeid = .$roadtypeid,
                          .modelcombination = .$modelCombination)) %>%
    setNames(., nm = rep("roadtype", length(.)))
  
  return(rlist)
  
}


              
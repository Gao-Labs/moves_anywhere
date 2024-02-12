#' @name what_level
#' @title Check What Level is my geoid
#' @author Tim Fraser
#' @param geoid (character) unique census geographic id for each county, state, county subdivision/municipality, nation, etc. 
#' @export
# Short function to check what level is the data you are analyzing, based on your input$geoid.
what_level = function(geoid){
  # Get total characters
  n = nchar(geoid)
  # If 00, that's nation.
  if(geoid == "00"){ "nation" 
    # If 2 digits and not 00, that's a state
  }else if(n == 2){ "state" 
    # If 5 digits, that a county
  }else if(n == 5){ "county"
    # If 11 digits, that's a county subdivision
  }else if(n == 11){ "muni"
  }else{ stop("level not known.") }
}
#' @name metadata
#' @title `metadata()`
#' @author Tim Fraser
#' 
#' @description
#' Write a function to find the correct set of headers for a given file type.
#' We only need to do this once per type of file (eg. 1 time for moa, 1 time for mo)
#' 
#' @param path path to example csv demonstrating movesoutput or movesactivity output tables for that `.level` of runs.
#' @param .level (character) county, state, or nation
#' 
#' @export
metadata = function(path, .level = "county"){
  
  # Testing Values
  # path = "data_raw/example_mo_nation.csv"
  # .level = "nation"

  require(dplyr)
  require(readr)
  require(purrr)
  require(stringr)
  
  # Gather all names
  .id = switch(.level, "county" = "countyID", "state" = "stateID", 
         "nation" = "stateID", "project" =  "projectID")
  namer = tribble(
    ~type,      ~old,       ~new,             ~class,            
    "all",      "yearID",   "year",           "col_integer()",    
    #"all",      "stateID",  "state",          "col_character()",  
    "all",      .id,         "geoid",         "col_character()",
    "emissions","pollutantID", "pollutant",   "col_integer()",  
    "all",      "sourceTypeID", "sourcetype",   "col_integer()",
    "all",      "regClassID",   "regclass",   "col_integer()",       
    "all",      "fuelTypeID",   "fueltype",   "col_integer()",       
    "all",      "roadTypeID",   "roadtype",   "col_integer()",       
    "emissions","emissionQuant", "emissions",   "col_double()",     
    "activity", "activityTypeID", "activitytype",   "col_integer()", 
    "activity", "activity",      "activity",   "col_double()",
  )
  # Using your file, import the first line of the file
  example = path %>% read_csv(n_max = 1)

  # Using your new file, get ALL variable names and their position
  allvars = tibble(old = example %>% names() ) %>%
    mutate(row = row_number()) %>%
    inner_join(by = c("old"), y = namer)
  
  types = allvars %>%
    with(set_names(.$class, nm = .$old)) %>%
    as.list() %>%
    map(~parse(text = .) %>% eval())
  
  vars = allvars %>% 
    # Get a named vector of column numbers and new names we will assign them
    with(set_names(.$row, .$new))
  
  labels = allvars %>%
    with(set_names(.$old, .$new))
  
  output = list("types" = types, "vars" = vars, "example" = example, "labels" = labels)
  
  # Save the example as a tempfile
  tmp = tempfile()
  example %>% write_csv(tmp)
  
  # Get type attribute
  .type = str_extract(path, pattern = "_mo|_mao")
  type = switch(.type, "_mo" = "emissions", "_mao" = "activity")
  output$type <- type

    # Read back in the temp file using the improved style
  # Get just the headers, with their file type, as a 0-row tibble,
  #source("data_raw/read_it.R")

  output$headers <- tmp %>% 
    read_it(n_max = 0, metadata = output) %>% slice(0) %>%
    bind_rows(tibble(geoid = NA_character_, year = NA_integer_))

  # Also, add type to the metadata package
  
  return(output)
}


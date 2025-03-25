
# Function to get vector of custom input table names
get_changes = function(BUCKET = "inputs"){
  # Grab csv files
  csvs = dir(BUCKET, pattern = ".csv")
  
  # Remove any of the output csvs, so we just have input csvs
  csvs = csvs[!csvs %in% c("data.csv", "training.csv", "movesoutput.csv", "movesactivityoutput.csv")]
  
  # If there are any custom input tables supplied, add their file paths to the p object  
  # if(length(csvs) > 0){ changes = paste0(BUCKET, "/", csvs) }else{ changes = NULL }
  
  if(length(csvs) > 0){
    
    data = tibble(
      changes = paste0(BUCKET, "/", csvs),
      changed = changes %>% stringr::str_remove(".*[/]") %>% tolower() %>% stringr::str_remove("[.]csv")
    )  
  }else{
    data = tibble(
      changes = vector(mode = "character", length = 0L),
      changed = vector(mode = "character", length = 0L)
    )
  }
  
  return(data)
}

# Let's write a tiny function for summarizing our data tables
counter = function(data){
  nums = dim(data)
  output = paste0(" [", nums[1], " x ", nums[2], "] ")
  return(output)
}


import_table = function(data, tablename, .custom, adapt = FALSE, save = FALSE, volume = "inputs"){
  # Add to a custom database called custom
  .custom = "custom"
  # If not empty...
  if(nrow(data) > 0){
    # Write a short function to quickly connect
    # custom = catr::connect("mariadb", .custom)
    # Truncate the table
    # dbExecute(conn = custom, statement = paste0("TRUNCATE TABLE ", tablename, ";"))
    # Write it to the custom database with that table name. 
    # (Append, not overwrite - you truncated the table in the line before, and appending means you keep the existing column schema)
    # DBI::dbWriteTable(conn = custom, name = tablename, value = data, overwrite = FALSE, append = TRUE)
    # Message
    if(adapt == TRUE){
      cat(paste0("\n---adapted default table:   ", tablename, counter(data)), "\n")
    }else if(adapt == FALSE){
      cat(paste0("\n---imported custom table:   ", tablename, counter(data)), "\n")
    }
    # Write to file, showing * to show that it is not custom
    if(save == TRUE){ data %>% readr::write_csv(paste0(volume, "/_", tablename, ".csv"))    }
    
    # Disconnect from database
    # dbDisconnect(custom)
  }
}

#' @name get_table
#' @description Get table from default input database
get_table = function(tablename){
  
  library(DBI)
  library(dplyr)
  library(catr)
  
  setwd("/cat/")
  
  rs = catr::translate_rs(.runspec = "EPA_MOVES_Model/rs_custom.xml")
  .custom = rs$defaultdbname
  custom = catr::connect("mariadb", .custom)
  
  data = custom %>% 
    tbl(tablename) %>%
    collect()
  
  dbDisconnect(custom)
  
  return(data) 
}

#' @name get_is_custom
#' @param files data.frame
#' @param table string
#' @description
#' Return a data.frame with a logical `is_custom` telling whether to grab the custom input table or not
get_is_custom = function(files, table){
  # Check if that custom input table is provided among the provided input tables
  f = files %>% filter(changed == table)
  # Get number of matching tables
  f_n = nrow(f)
  # Error handling
  if(f_n > 1){ stop("Multiple MOVES input files of the same name provided. Stopping...")}
  
  # Is the table of interest provided as a custom input file?
  is_custom = f_n == 1
  
  if(f_n == 0){
    f = tibble(changed = table, is_custom = is_custom)
  }
  if(f_n == 1){
    f$is_custom = is_custom 
  }
  return(f)
}

get_data = function(changes, .geoidchar = NULL){
  # Load in data
  data = readr::read_csv(changes, show_col_types = FALSE, progress = FALSE) %>%
    setNames(nm = names(.) %>% tolower())  
  
  # if contains a fips column / fip
  if("fip" %in% names(data)){
    data = data %>%
      mutate(fip = stringr::str_pad(fip, width = 5, pad = "0", side = "left")) %>%
      filter(fip == .geoidchar)            
  }
  if("fips" %in% names(data)){
    data = data %>%
      mutate(fips = stringr::str_pad(fips, width = 5, pad = "0", side = "left")) %>%
      filter(fips == .geoidchar)            
  }
  # Return just distinct rows
  data = data %>% distinct()
  return(data)
}



# # Supporting script, not for deployment
# get_names = function(table){
#   x = translators::inputs[[table]] %>% with(
#     tibble(name = tolower(names(.)),
#            nm = names(.))) %>%
#     mutate(var = paste0('"', nm, '" = "', name, '"')) %>%
#     with(var)
# 
#   n_x = length(x)
# 
#   if(n_x > 1){
#     bundle = paste0(x[-n_x], collapse = ",\n")
#     output = paste0("data = data %>% \n", "select(\n", bundle, ",\n", x[n_x], "\n)" )
#   }else if(n_x == 1){
#     output = paste0("data = data %>% \n", "select(\n", x, "\n)" )
#   }
#   cat(output)
# 
# }

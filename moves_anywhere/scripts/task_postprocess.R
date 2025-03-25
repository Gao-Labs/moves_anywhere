# task_postprocess.R

# Task to postprocess MOVES data

library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
library(readr, warn.conflicts = FALSE, quietly = TRUE)
library(catr, warn.conflicts = FALSE, quietly = TRUE)

# Load environmental variables
# source("setenv.r")

# Get runspec metadata
rs = catr::translate_rs(.runspec = "inputs/rs_custom.xml")

if(rs$mode == "inv"){
  
  # Either way, extract this data.
  # Grab movesoutput and movesactivityoutput as .csvs in the mounted inputs/ folder
  library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  library(catr, warn.conflicts = FALSE, quietly = TRUE)
  library(readr, warn.conflicts = FALSE, quietly = TRUE)
  library(RMariaDB, warn.conflicts = FALSE, quietly = TRUE)
  db = catr::connect(type = "mariadb", "moves")
  db %>% tbl("movesoutput") %>% collect() %>% write_csv("inputs/movesoutput.csv")
  db %>% tbl("movesactivityoutput") %>% collect() %>% write_csv("inputs/movesactivityoutput.csv")
  DBI::dbDisconnect(db)
  
  
  # Does your directory contain a parameters file?
  has_json = file.exists("inputs/parameters.json")
  
  # Only create inputs/data.csv if a series of things are true.
  # If json is present, create inputs/data.csv
  if(has_json == TRUE){
    
    # Import the parameters
    p = jsonlite::fromJSON("inputs/parameters.json")
    
    
    # Is this a training run that was randomized? If so, then do not post-process the data.
    # p = list(training_type = "randomized", other = 1, by = c(16, 1))
    condition_training = any("training_type" %in% names(p))
    
    # If it is a training run - check and see - is it a randomized run? If so, we don't want to data-ify those.
    if(condition_training == TRUE){
      condition_randomized = p$training_type == "randomized"
      # If it's not a training run, it's not a randomized run.
    }else{condition_randomized = FALSE }
    
    # If it is NOT a randomized training run... 
    if(condition_randomized == FALSE){
      
      # Check if it has the by fields
      condition_by = any("by" %in% names(p))
      # If it has by vars, use them. Otherwise, supply these defaults.
      if(condition_by == TRUE){ by_vars = p$by }else{ by_vars = c(1,16,15,14,12,8)}
      
      # Post process the data
      path = postprocess_format(
        path_data = "data.rds", csv = FALSE, 
        by = by_vars, pollutant = NULL, 
        path_parameters = "inputs/parameters.json")
      
      print(path)
      
      # Check it
      path %>% readr::read_rds() %>% head()
      
      # Write it to file as .csv in the mounted inputs/ folder.
      read_rds("data.rds") %>% write_csv("inputs/data.csv")
    }
    
  }
  
  
}else if(rs$mode == "rates"){
  
  library(catr, warn.conflicts = FALSE, quietly = TRUE)
  library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  library(readr, warn.conflicts = FALSE, quietly = TRUE)
  library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  library(RMySQL, warn.conflicts = FALSE, quietly = TRUE)
  
  db = catr::connect("mariadb", "moves")
  db %>% dbListTables()
  db %>% tbl("rateperhour") %>% collect() %>% readr::write_csv("inputs/rateperhour.csv")
  db %>% tbl("ratepervehicle") %>% collect() %>% readr::write_csv("inputs/ratepervehicle.csv")
  db %>% tbl("rateperdistance") %>% collect() %>% readr::write_csv("inputs/rateperdistance.csv")
  db %>% tbl("rateperstart") %>% collect() %>% readr::write_csv("inputs/rateperstart.csv")
  db %>% tbl("startspervehicle") %>% collect() %>% readr::write_csv("inputs/startspervehicle.csv")
  db %>% tbl("rateperprofile") %>% collect() %>% readr::write_csv("inputs/rateperprofile.csv") # usually empty
  db %>% tbl("movesrun") %>% collect() %>% readr::write_csv("inputs/movesrun.csv") # usually small
  
  dbDisconnect(db)
  
}

# Close out of script
q(save = "no")
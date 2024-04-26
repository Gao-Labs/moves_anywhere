#' @name postprocess_upload.r
#' @title postprocessing upload code run AFTER invoking MOVES
#' @author Tim Fraser

# library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
# library(readr, warn.conflicts = FALSE, quietly = TRUE)

# Set main paths used in this script
env = '.Renviron'
parameters ="inputs/parameters.json"
# Specify the output file path from postprocess.R - should be data.csv
path = "inputs/data.csv"

# Check if an .Renviron file exists
env_exists = file.exists(env)

# If the .Renviron file has NOT been supplied...
if(env_exists == FALSE){
  
  message = paste0(
    "\n",
    "\n",
    "No mounted .Renviron file found, so results will not be uploaded to a server.",
    "\n",
    "If you didn't plan to upload these results to a server, please disregard!",
    "\n",
    "\n")
  cat(message)
  
  # If the .Renviron file has been supplied...
}else if(env_exists == TRUE){
  
  # Read Environmental Variables for ORDERDATA_
  readRenviron(env)
  
  # Takes place of this code...
  # Set environmental variables
  # Sys.setenv("ORDERDATA_USERNAME" = "userapi")
  # Sys.setenv("ORDERDATA_PASSWORD" = "*************")
  # Sys.setenv("ORDERDATA_HOST" = "128.253.5.67")
  # Sys.setenv("ORDERDATA_PORT" = "3306")
  
  # Load upload function
  source("upload.r")
  
  # Load in your parameters
  p = jsonlite::fromJSON(parameters) 
  
  # Check if your parameters file has variable 'dtablename'
  has_dtablename = any(names(p) %in% "dtablename")
  
  # If parameteres has dtablename, run the upload code.
  if(has_dtablename == TRUE){
    
    # By default
    overwrite = TRUE; append = FALSE
    
    # Check if your parameters file has variable 'multiple'
    has_multiple = any(names(p) %in% "multiple")
    
    # If your parameters file has the variable 'multiple
    if(has_multiple == TRUE){
      # If the 'multiple' argument is TRUE,
      # that means this is just one of many MOVES runs that will all go in one table on CATSERVER.
      # So append; don't overwrite.
      if(p$multiple == TRUE){ overwrite = FALSE; append = TRUE}
    }
    # Otherwise, just keep the defaults specified above - you'll overwrite/write a new table.
    
    # Upload table to CATSERVER
    upload(
      data = readr::read_csv(path), 
      table = p$dtablename, 
      overwrite = overwrite, append = append)
    
    # Load check() function
    source("check.r")
    
    # Check if the data got uploaded!
    check(parameters = parameters, env = env)
    
    # If the parameters.json file has no dtablename... 
  }else if(has_dtablename == FALSE){
    message = paste0(
      "\n", "---------------------------","\n",
      "'dtablename' not provided in parameters.json. No files will be uploaded to server.",
      "\n", "---------------------------","\n")
    cat(message, sep = "\n")
    
  }  
}

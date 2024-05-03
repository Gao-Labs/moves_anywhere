#' @name postprocess_upload.r
#' @title postprocessing upload code run AFTER invoking MOVES
#' @author Tim Fraser

require(dplyr, warn.conflicts = FALSE, quietly = TRUE)
require(readr, warn.conflicts = FALSE, quietly = TRUE)
require(purrr, warn.conflicts = FALSE, quietly = TRUE)
require(jsonlite, warn.conflicts = FALSE, quietly = TRUE)

# Set main paths used in this script
#env = 'secret1/.Renviron'
parameters ="inputs/parameters.json"
# Specify the output file path from postprocess.R - should be data.csv
path = "inputs/data.csv"
key = "secret/runapikey.json"
# Paths to certificates for database
# cert = c("secret2/server-ca.pem", "secret3/client-cert.pem", "secret4/client-key.pem")
# Working directory path
working_dir = getwd()
# Bundle varaibles
# vars = c(env, parameters, path, cert, working_dir)
vars = c(parameters, path, key, working_dir)
# Get file information for each dependency.
info = file.info(vars) %>%
  as_tibble(rownames = "file") %>%
  mutate(exists = if_else(!is.na(size), TRUE, FALSE)) %>%
  select(file, exists, isdir, mode) %>%
  mutate(id = 1:n())

# For each file, concatenate the output
message = info %>%
  split(.$id) %>%
  map(~paste0("file_exists: ", .x$exists, " | ",
              "folder: ", .x$isdir, " | ",
              "file: ", .x$file, " | ", "\n") ) %>%
  paste0(collapse = "") %>%
  paste0("\n---FILE CHECK----------------------------\n", ., 
         "-----------------------------------------\n")
cat(message)


# Load upload function
source("upload.r")
# Load the fieldtypes
source("fieldtypes.r")

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
    fieldtypes = fieldtypes, # generated in fieldtypes.r
    overwrite = overwrite, append = append)
  
  
  # If the parameters.json file has no dtablename... 
}else if(has_dtablename == FALSE){
  message = paste0(
    "\n", "---------------------------","\n",
    "'dtablename' not provided in parameters.json. No files will be uploaded to server.",
    "\n", "---------------------------","\n")
  cat(message, sep = "\n")
  
}  


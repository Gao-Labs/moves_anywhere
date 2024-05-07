#' @name workflow.R
#' @description
#' Trigger several MOVES run jobs to cover an entire scenario.
#' Traditionally, each scenario is a year.
#' Each job would normally receive its own bucket,
#' but for a multi-year scenario, each job receives a folder in its own bucket.

setwd(rstudioapi::getActiveProject())
setwd("demos/demo_scenario")

# Load packages
library(dplyr)
library(catr)

key_path = "../../runapikey.json" # path to your private runapikey.json
project = "moves-runs" # project name
region = "us-central1" # region name
# Provide a dtablename - the name of the table that you'll end up with.
dtablename = "d36109_u1_o22"
# Convert that to a bucket name - can't have underscores.
bucket = gsub(x = dtablename, pattern = "[_]", replacement = "-")
# Write out paths
folder = "./volume"   # path to folder for mounting

# Make a folder
dir.create(folder, showWarnings = FALSE)

runs = tibble(
  years = c(2020, 2025, 2030),
  id = 1:length(years),
  folder = paste0(folder),
  group = paste0("r", years),
  subfolder = paste0(folder, "/", group),
  path_rs = paste0(subfolder, "/rs_custom.xml"),
  path_parameters = paste0(subfolder, "/parameters.json"),
  dtablename = dtablename,
  bucket = gsub(x = paste0(dtablename, "_", group), pattern = "[_]", replacement = "-")
)

runs

# Authorize
auth = movesrunner::authorize(key_path = key_path)

# Try to delete each bucket if present
for(i in runs$id){
  catr::object_delete_bulk(bucket = runs$bucket[i], token = auth$credentials$access_token)
  catr::bucket_delete(bucket = runs$bucket[i], token = auth$credentials$access_token)
}

# Make a bucket and upload contents, one-by-one.

for(i in runs$id){
  # Create folder for run
  dir.create(runs$subfolder[i], showWarnings = FALSE)
  
  # Make a runspec (must have catr loaded to use the data 'rs_template')
  catr::custom_rs(
    .geoid = "36109", .year = runs$years[i], .level = "county", .default = FALSE,
    .path = runs$path_rs[i],
    .geoaggregation = "county", .timeaggregation = "year", .rate = FALSE
  )
  # Make a parameters.json from the runspec
  catr::rs_to_parameters(
    path_rs = runs$path_rs[i], path_parameters = runs$path_parameters[i],
    by = c(1,16,8,12,14,15), 
    tablename = dtablename, # all runs will get written to this one table 
    multiple = TRUE # for a scenario set of runs, multiple MUST BE TRUE!
  )
  
  # Make a storage bucket
  try(expr = catr::bucket_create(bucket = runs$bucket[i], project = project, region = region), 
      silent = FALSE)
  
  # Upload files in bulk
  try(expr = catr:::bucket_upload_bulk(
    bucket = runs$bucket[i], folder = runs$subfolder[i], last_file = runs$path_rs[i], 
    token = auth$credentials$access_token),
    silent = FALSE)
  
  Sys.sleep(0.1)
}


# It works!
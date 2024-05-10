#' @name workflow_inv.R
#' @description 
#' A script that demos a triggered workflow.
#' Tests a workflow 

# Get your active project from rstudioapi package
setwd(rstudioapi::getActiveProject())
setwd("demos/demo_run")

# Load package
library(dplyr)
library(catr)


key_path = "../../runapikey.json" # path to your private runapikey.json
project = "moves-runs" # project name
region = "us-central1" # region name

# Get a new bucket name yet unused
bucket = get_new_bucket_name(geoid = "36109", user = 1, project = project, key_path = key_path)
# Provide a dtablename - the name of the table that you'll end up with.
dtablename = name_bucket_to_table(bucket)

# Write out paths
folder = "./volume_inv"   # path to folder for mounting

# Convert that to a bucket name - can't have underscores.
bucket = gsub(x = dtablename, pattern = "[_]", replacement = "-")
path_rs = paste0(folder, "/rs_custom.xml") # path to runspec file
path_parameters = paste0(folder, "/parameters.json") # path to parameters.json

# Make that folder, if needed
dir.create(folder, showWarnings = FALSE)

# Make a runspec (must have catr loaded to use the data 'rs_template')
catr::custom_rs(
  .geoid = "36109", .year = 2020, .level = "county", .default = FALSE,
  .path = path_rs,
  .pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107,116, 117),
  .geoaggregation = "county", .timeaggregation = "year", .rate = FALSE
)

# Make a parameters.json from the runspec
catr::rs_to_parameters(
  path_rs = path_rs, path_parameters = path_parameters,
  tablename = dtablename, by = c(1,16,8,12,14,15)
)

# Make any custom input tables
# This uses translators, a beta feature not yet public.
# library(dplyr)
# library(readr)
# library(translators)
# 
# readRenviron("../.Renviron") # You'll need .Renviron of CAT dashboard read-only credentials for CATSERVER
# translators::get_sourcetypeyear_cat(.year = 2020, .table = "d36109", .pollutant = 98) %>%
#   mutate(sourceTypePopulation = case_when(sourceTypeID == 11 ~ sourceTypePopulation * 5, TRUE ~ sourceTypePopulation)) %>%
#   write_csv(paste0(folder, "/sourcetypeyear.csv"))


# Authorize
auth = catr::authorize(key_path = key_path)

# Delete the bucket if present
catr::object_delete_bulk(bucket = bucket, token = auth$credentials$access_token)
catr::bucket_delete(bucket = bucket, token = auth$credentials$access_token)

# Make a storage bucket
catr::bucket_create(bucket = bucket, project = project, region = region)

# Upload files in bulk
catr:::bucket_upload_bulk(bucket = bucket, folder = folder, last_file = "rs_custom.xml", token = auth$credentials$access_token)

# Trigger will now execute...

# Check Bucket Status Here:
# https://console.cloud.google.com/storage/browser?forceOnBucketsSortingFiltering=true&authuser=1&hl=en&project=moves-runs&supportedpurview=project&prefix=&forceOnObjectsSortingFiltering=false

# Check MOVES Workflow Status Here:
# https://console.cloud.google.com/workflows/workflow/us-central1/run-moves/executions?authuser=1&hl=en&project=moves-runs&supportedpurview=project

# Check Jobs Status Here:
# https://console.cloud.google.com/run/jobs?authuser=1&project=moves-runs&supportedpurview=project

# Check Upload Workflow Status Here:
# https://console.cloud.google.com/workflows/workflow/us-central1/upload-data/executions?authuser=1&hl=en&project=moves-runs&supportedpurview=project

# Check CAT Cloud Here:
# https://console.cloud.google.com/sql/instances/catcloud/overview?authuser=1&hl=en&project=moves-runs

# When finished...

# Delete the bucket if present
catr:::object_delete_bulk(bucket = bucket, token = auth$credentials$access_token)
catr::bucket_delete(bucket = bucket, token = auth$credentials$access_token)



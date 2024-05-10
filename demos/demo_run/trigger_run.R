#' @name trigger_run
#' @title Trigger a single Cloud MOVES run
#' @export
trigger_run = function(geoid = "36109", year = 2020, level = "county", default = FALSE, 
                       geoaggregation = "county", timeaggregation = "year", rate = FALSE,
                       pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107,116, 117), # CAT Pollutants - grabs dependencies too
                       sourcetypes = NULL, fueltypes = NULL, roadtypes = NULL, # this means use all
                       user = 1, folder = "./volume", by = c(1,16,8,12,14,15),
                       project = "moves-runs", region = "us-central1",
                       folder, key_path){

  # Testing values
  # key_path = "../../runapikey.json" # path to your private runapikey.json
  # project = "moves-runs" # project name
  # region = "us-central1" # region name

  # Load package
  library(dplyr, quietly = TRUE)
  library(catr, quietly = TRUE)
  
  # Get a new bucket name yet unused
  bucket = get_new_bucket_name(geoid = geoid, user = user, project = project, key_path = key_path)
  # Provide a dtablename - the name of the table that you'll end up with.
  dtablename = name_bucket_to_table(bucket)
  
  # Write out paths
  # folder = "./volume_inv"   # path to folder for mounting
  
  # Convert that to a bucket name - can't have underscores.
  bucket = gsub(x = dtablename, pattern = "[_]", replacement = "-")
  path_rs = paste0(folder, "/rs_custom.xml") # path to runspec file
  path_parameters = paste0(folder, "/parameters.json") # path to parameters.json
  
  # Make that folder, if needed
  dir.create(folder, showWarnings = FALSE)
  
  # Make a runspec (must have catr loaded to use the data 'rs_template')
  catr::custom_rs(
    .geoid = geoid, .year = year, .level = level, .default = default,
    .path = path_rs,
    .pollutants = pollutants, .sourcetypes = sourcetypes, .fueltypes = fueltypes, .roadtypes = roadtypes,
    .geoaggregation = geoaggregation, .timeaggregation = timeaggregation, .rate = rate
  )
  
  # Make a parameters.json from the runspec
  catr::rs_to_parameters(
    path_rs = path_rs, path_parameters = path_parameters,
    tablename = dtablename, by = by
  )

  # Authorize
  auth = catr::authorize(key_path = key_path)
  
  # # Delete the bucket if present
  
  # Make a storage bucket
  b1 = catr::bucket_create(bucket = bucket, project = project, region = region)
  
  # Upload files in bulk
  b2 = catr:::bucket_upload_bulk(bucket = bucket, folder = folder, last_file = "rs_custom.xml", token = auth$credentials$access_token)
  
  # Trigger will now execute...
  output = list(create = b1, upload = b2)
  return(output)
}
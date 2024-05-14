#' @name get_scenario
#' @description
#' Function for generating an up-to-date picture of NY counties

get_scenario = function(user, geoid, years = seq(from = 1990, to = 2060, by = 5), by = c(1,16,8,12,14,15),
                        level = "county", default = FALSE, 
                        geoaggregation = "county", timeaggregation = "year", rate = FALSE,
                        pollutants = c(98, 3, 87, 2, 31, 33, 110, 100, 106, 107, 116, 117),
                        project = "moves-runs", # project name
                        region = "us-central1", # region name
                        key_path){
  
  # Get new bucket_name
  bucket = catr::get_new_bucket_name(geoid = geoid, user = user, project = project, type = "d", key_path = key_path)
  dtablename = catr::name_bucket_to_table(bucket)
  folder = paste0("./", dtablename)
  
  
  
  # Make a folder
  dir.create(folder, showWarnings = FALSE)
  
  runs = tibble(
    years = years,
    id = 1:length(years),
    folder = paste0(folder),
    group = paste0("r", years),
    subfolder = paste0(folder, "/", group),
    path_rs = paste0(subfolder, "/rs_custom.xml"),
    path_parameters = paste0(subfolder, "/parameters.json"),
    dtablename = dtablename,
    bucket = gsub(x = paste0(dtablename, "_", group), pattern = "[_]", replacement = "-")
  )
  
  
  # Authorize
  auth = catr::authorize(key_path = key_path)
  
  # # Try to delete each bucket if present
  # for(i in runs$id){
  #   catr::object_delete_bulk(bucket = runs$bucket[i], token = auth$credentials$access_token)
  #   catr::bucket_delete(bucket = runs$bucket[i], token = auth$credentials$access_token)
  # }
  
  
  
  # Make a bucket and upload contents, one-by-one.
  
  for(i in runs$id){
    # Create folder for run
    dir.create(runs$subfolder[i], showWarnings = FALSE)
    
    
    cat("\n---translating custom input tables...\n")
    
    # Use translator functions to generate basic custom input tables
    # get_sourcetypeyear_def(.year = runs$years[i], .geoid = geoid) %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/sourcetypeyear.csv"))
    # 
    # get_hpmsvtypeyear_def(.year = runs$years[i], .geoid = geoid) %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/hpmsvtypeyear.csv"))
    
    # get_hourvmtfraction_def() %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/hourvmtfraction.csv"))
    
    # get_sourcetypeagedistribution_def(.year = runs$years[i]) %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/sourcetypeagedistribution.csv"))
    
    # get_imcoverage_def(.county = geoid, .year = runs$years[i]) %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/imcoverage.csv"))
    
    # get_avgspeeddistribution_def() %>%
    #   write_csv(file = paste0(runs$subfolder[i], "/avgspeeddistribution.csv"))
    
    
    
    # Make a runspec (must have catr loaded to use the data 'rs_template')
    cat("\n---writing runspec...\n")
    catr::custom_rs(
      .geoid = geoid, .year = runs$years[i], 
      .level = level, .default = default,
      .path = runs$path_rs[i],
      .pollutants = pollutants,
      .geoaggregation = geoaggregation, .timeaggregation = timeaggregation, .rate = rate
    )
    # Make a parameters.json from the runspec
    catr::rs_to_parameters(
      path_rs = runs$path_rs[i], path_parameters = runs$path_parameters[i],
      by = by, 
      tablename = dtablename, # all runs will get written to this one table 
      multiple = TRUE # for a scenario set of runs, multiple MUST BE TRUE!
    )
    
    # Make a storage bucket
    cat("\n---creating bucket...\n")
    try(expr = catr::bucket_create(bucket = runs$bucket[i], project = project, region = region), 
        silent = FALSE)
    
    # Upload files in bulk
    cat("\n---uploading to bucket...\n")
    try(expr = catr:::bucket_upload_bulk(
      bucket = runs$bucket[i], folder = runs$subfolder[i], last_file = runs$path_rs[i], 
      token = auth$credentials$access_token),
      silent = FALSE)
    
    Sys.sleep(0.1)
  }
  
}

# list(
#   fromdbname = "orderdata",
#   fromdbtable = "d36109_u1_o18",
#   todbname = "granddata",
#   todbtable =  "dABCDE"
# ) %>%
#   workflow_execute(workflow_name = "orderdata-to-granddata", body = ., project = "moves-runs", region = "us-central1", token = auth$credentials$access_token)

# It works!
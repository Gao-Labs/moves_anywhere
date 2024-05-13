#' @name authorize
#' @title Authenticate with Google Cloud using an API key json
#' @param key_path path to API key .json file
#' @importFrom gargle credentials_service_account
#' @importFrom googleAuthR gar_auth
#' @returns A list object containing service account credentials.
#' @export
authorize = function(key_path){
  
  # Get an authorization token
  auth = gargle::credentials_service_account(
    path = key_path,
    scopes = "https://www.googleapis.com/auth/cloud-platform")
  
  ## Authorize using token
  googleAuthR::gar_auth(token = auth)
  
  return(auth)
}



#' @name read_api
#' @title Read contents of a REST API call response
#' @param response REST API call response object
#' @importFrom dplyr `%>%`
#' @importFrom jsonlite fromJSON
#' @export
read_api = function(response){ fromJSON(rawToChar(response$content)) }

#' @name check_response
#' @title Check and Report Response Status of a REST API Call
#' @param response REST API call response object
#' @importFrom httr http_status
#' @export
check_response = function(response){
  type = response$request$method
  # Check if request was successful
  if (httr::http_status(response)$category == "Success") {
    cat(paste0("\n", type, " request successful.\n"))
  } else {
    cat(paste0("\n", type, " request failed.\n"))
  }
}

#' @name bucket_list
#' @title LIST BUCKETS
#' @source https://cloud.google.com/storage/docs/listing-buckets#rest-list-buckets
#' @param project "moves_runs"
#' @param token ...
#' @importFrom httr GET add_headers
#' @export
bucket_list = function(project = "projectname", token){
  # library(dplyr)
  # library(httr)
  # library(jsonlite)
  base = "https://storage.googleapis.com/storage/v1/b?project="
  url = paste0(base, project)
  
  headers = add_headers(
    "Authorization" = paste("Bearer ", token),
    "Content-Type" = "application/json"
  )
  
  response = GET(url = url, headers)
  
  # Check if request was successful
  check_response(response)
  
  return(response)
}

#' @name bucket_create
#' @title Create Bucket
#' @description
#' Simple wrapper function around googleCloudStorageR functions
#' Requires you to have already authorized with `authorize()`
#' @param bucket eg. "projectname-d36109-u1-o1"
#' @param project Name of project "projectname"
#' @param region "us-central1"
#' @param ... Any other arguments to pass to `gcs_create_bucket()`
#'  
#' @importFrom googleCloudStorageR gcs_create_bucket
#' @export
bucket_create = function(bucket, project, region, ...){
  gcs_create_bucket(
    name = bucket, projectId = project, 
    location = region, storageClass = "STANDARD", ...)
}

#' #' @name bucket_create_old
#' #' @title Make Storage bucket
#' #' @note docker exec gcloud gcloud storage buckets create "gs://input-$BUCKET"
#' #' @param bucket_name ...
#' #' @param bucket_location https://cloud.google.com/storage/docs/locations
#' #' @param storage_class https://cloud.google.com/storage/docs/storage-classes
#' #' @param project should be "projectname"
#' #' @param token ...
#' #' @importFrom httr POST add_headers
#' #' @export
#' bucket_create = function(bucket_name, bucket_location = "us-central1", 
#'                          storage_class = 'STANDARD', project = "projectname", token) {
#'   
#'   # library(dplyr)
#'   # library(httr)
#'   # library(jsonlite)
#'   
#'   # Make json list data
#'   body = list(
#'     name = bucket_name,
#'     location = bucket_location,
#'     storageClass = storage_class,
#'     iamConfiguration = list(uniformBucketLevelAccess = list(enablled = TRUE))
#'   )
#'   
#'   # Prepare the request
#'   url = paste0("https://storage.googleapis.com/storage/v1/b?project=", project)
#'   headers = add_headers(
#'     "Authorization" = paste("Bearer ", token),
#'     "Content-Type" = "application/json"
#'   )
#'   # Send the POST request
#'   response <- POST(url = url, body = body, encode = "json", headers)
#'   
#'   # Check if request was successful
#'   check_response(response)
#'   
#'   
#'   # Return the response
#'   return(response)
#' }


#' @name folder_to_files
#' @title Folder to Files
#' @description 
#' Convert folder name into a `tbl` of file paths, buckets, and content-types
#' @param folder name of folder, eg. "d36109_u1_o12"
#' @importFrom dplyr `%>%` tibble mutate case_when n
#' @importFrom stringr str_extract str_remove
#' @export
folder_to_files = function(folder, bucket, scenario = FALSE){
  # testing
  # folder = "volume_inv"
  # Get a tibble of all files
  files = tibble(
    path = dir(folder, full.names = TRUE,recursive = TRUE),
    name = str_remove(path, ".*/")
  )
  
  if(scenario == FALSE){
    # Get the end file name.    
  }else if(scenario == TRUE){
    files = files %>%
      mutate(subfolder = path %>% dirname() %>% str_remove(".*/")) %>%
      mutate(name = paste0(subfolder, "/", name))
  }
  
  files = files %>%
    mutate(
      type = name %>% str_extract("[.](json|csv|xml)"),
      type = case_when(
        type == ".json" ~ "application/json",
        type == ".csv" ~ "text/csv",
        type == ".xml" ~ "application/xml"),
      bucket = bucket,
      id = 1:n()
    )
  return(files)
}




#' @name bucket_upload
#' @title Upload File to Bucket
#' 
#' @param path Path of File to be uploaded
#' @param name Name for file to receive in bucket
#' @param type content-type, eg. "application/json" or "text/csv"
#' @param bucket eg. "projectname-d36109-u1-o12"
#' @param token ...
#' 
#' @importFrom httr add_headers POST
#' @export
bucket_upload = function(path, name, type, bucket, token){
  
  # require(httr)
  # require(jsonlite)
  
  data = readBin(path, "raw", file.size(path))
  
  # Construct the URL
  url <- paste0("https://storage.googleapis.com/upload/storage/v1/b/", bucket, "/o?uploadType=media&name=", name)
  
  # Construct the headers
  headers <- add_headers(.headers = c(
    "Authorization" = paste("Bearer ", token),
    "Content-Type" = type
  ))
  
  # Make the POST request
  response = POST(url, body = data, headers)
  # Check if request was successful
  check_response(response)
  
  return(response)
  
}

#' @name bucket_delete
#' @title Delete Cloud Storage Bucket
#' @param bucket name of bucket for deletion (must be empty)
#' @param recursive TRUE
#' @param token ...
#' 
#' @description
#' curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#" https://storage.googleapis.com/storage/v1/b/BUCKET_NAME"
#' 
#' @importFrom httr DELETE add_headers
#' @export
bucket_delete = function(bucket, recursive = TRUE, token){
  
  # require(httr)
  # require(jsonlite)
  # require(dplyr)
  url = paste0("https://storage.googleapis.com/storage/v1/b/", bucket)
  # Construct the headers
  headers = add_headers(.headers = c(
    "Authorization" = paste("Bearer ", token)
  ))
  query = list(recursive = recursive)
  # Make DELETE request
  response = DELETE(url = url, query = query, headers)    
  # Check if request was successful
  check_response(response)
  
  return(response)
}

#' @name object_list
#' @title List Objects in a Google Cloud Storage Bucket
#' @param bucket name of storage bucket, eg. 'projectname-d36109-u1-o12'
#' @param token ...
#' @importFrom httr add_headers GET
#' @export
object_list = function(bucket, token){
  # require(dplyr)
  # require(httr)
  # require(jsonlite)
  url = paste0("https://storage.googleapis.com/storage/v1/b/", bucket, "/o")
  
  headers = add_headers(
    "Authorization" = paste("Bearer ", token),
    "Content-Type" = "application/json"
  )
  
  response = GET(url = url, headers)
  
  # Check if request was successful
  check_response(response)
  
  return(response)
}

#' @name object_delete
#' @title Delete Object from Storage Bucket
#'
#' @param file file for deletion from bucket
#' @param bucket name of bucket eg. "projectname-d36109-u1-o12"
#' @param token ...
#'
#' @importFrom httr DELETE add_headers
#' @export
object_delete = function(file, bucket, token){
  
  # require(httr)
  # require(jsonlite)
  # require(dplyr)
  url = paste0("https://storage.googleapis.com/storage/v1/b/", bucket, "/o/", file)
  # Construct the headers
  headers = httr::add_headers(.headers = c(
    "Authorization" = paste("Bearer ", token)
  ))
  # Make DELETE request
  response = httr::DELETE(url = url, headers)    
  # Check if request was successful
  check_response(response)
  
  return(response)
  
}

#' @name object_delete_bulk
#' @title Delete Objects in Bulk
#' @param bucket ...
#' @param token ...
#' @export
object_delete_bulk = function(bucket, token){
  response = movesrunner::object_list(bucket = bucket, token = auth$credentials$access_token)
  objects = jsonlite::fromJSON(rawToChar(response$content))
  for(i in objects$items$name){
    object_delete(file = i, bucket = bucket, token = auth$credentials$access_token)
  }
}



#' @name job_get
#' @title Get Job Details
#' 
#' @param job_name name of job
#' @param project "projectname"
#' @param region "us-central1"
#' @param token ...
#' 
#' @description
#' curl -H "Content-Type: application/json" \
#' -H "Authorization: Bearer ACCESS_TOKEN" \
#' -X GET \
#' -d '' \
#' https://run.googleapis.com/v2/projects/PROJECT_ID/locations/REGION/jobs/JOB-NAME
#'
#' @importFrom httr add_headers GET
#' @export
job_get = function(job_name, project= "projectname", region = "us-central1", token){
  
  # https://cloud.google.com/run/docs/reference/rest/v2/projects.locations.jobs/get
  require(httr)
  require(jsonlite)
  require(dplyr)
  
  # Make URL
  url = paste0("https://run.googleapis.com/v2/projects/", project, "/locations/", region, "/jobs/", job_name)
  
  # Make authorization header
  headers = add_headers(
    "Authorization" = paste("Bearer ", token),
    "Content-Type" = "application/json"
  )
  
  response = GET(url = url, encode = "json", headers)
  
  check_response(response)
  
  return(response)
  
}





#' @name bucket_name
#' @title Get name of bucket
#' @description
#' Convert a dtablename into a bucket name
#' 
#' @param dbtablename name of eventual data table, eg. "d36109_u1_o12"
#' @param project Name of project with linked billing ID - "projectname"
#' 
#' @export
bucket_name = function(dtablename, project = "projectname"){
  # Take dtablename - this will be the name of the folder for upload too
  # Recode the underscores into dashes.
  dtablename_gc = gsub("[_]", replacement = "-", x = dtablename)
  # Get bucket name
  bucket = paste0(project, "-", dtablename_gc)
  return(bucket)
}



#' @name bucket_upload_bulk
#' @title Upload Objects in Bulk
#' @param bucket ...
#' @param token ...
#' @export
bucket_upload_bulk = function(bucket, folder, last_file = NULL, token, scenario = FALSE){
  # Testing values
  # last_file = "rs_custom.xml"
  
  # Convert folder name to tibble of files
  files = folder_to_files(folder = folder, bucket = bucket, scenario = scenario)
  
  # If you specify a file to come last, upload that one last.
  if(!is.null(last_file)){
    files = files %>%
      mutate(last = case_when(
        str_detect(path, last_file) ~ TRUE,
        TRUE ~ FALSE)) %>%
      # Reorder and overwrite the id
      arrange(last, id) %>%
      mutate(id = 1:n())
  }
  
  output = files %>% 
    split(.$id) %>%
    purrr::map(~bucket_upload(
      path = .$path, bucket = .$bucket, name = .$name,  type = .$type,
      token = token), .id = "id")
  
  # Check status
  status = output %>% purrr::map_int(~.$status_code)
  if(any(status != 200)){ stop("File upload to bucket failed.")  }
  
}

#' @name name_bucket_to_table
#' @title Convert Bucket Name to Table Name
#' @description
#' Convert a bucketname to a tablename
#' @export
name_bucket_to_table = function(bucket){
  #bucket = "d36109-u1-o1"  
  gsub(x = bucket, pattern = "[-]", replacement = "_")
}
#' @name name_table_to_bucket
#' @title Convert Table Name to Bucket Name
#' @description
#' Convert a tablename to a bucketname
#' @export
name_table_to_bucket = function(table){
  #table = "d36109_u1_o1"
  gsub(x = table, pattern = "[_]", replacement = "-")
}

#' @name get_new_bucket_name
#' @title Get New Bucket Name
#' @description
#' We'll have trouble if we ask it to use a bucket name already in use. 
#' So, this function will return the next available bucket name for a given user.
#' 
#' @param geoid eg. "36109"
#' @param user eg. 1
#' @param type eg. "d" for an inventory "data" table.
#' @param project eg. "projectname"
#' @param key_path eg. "runapikey.json"
#' @param max_results eg. 100
#' 
#' @importFrom googleCloudStorageR gcs_list_buckets
#' @importFrom dplyr `%>%` select filter summarize
#' @importFrom stringr str_remove str_detect
#' @importFrom readr parse_integer
#' 
#' @export
get_new_bucket_name = function(geoid = "36109", user = 1, project = "projectname", type = "d",
                               key_path = "runapikey.json", max_results = 100){
  # Testing values
  # key_path = "../../runapikey.json"; project = "moves-runs"; max_results = 100
  # user = 1; geoid = "36109"; type = "d"
  # library(stringr)
  # library(dplyr)
  
  # Authenticate 
  # Get an authorization token
  auth = authorize(key_path = key_path)
  # Create prefix for searching through that user's existing buckets
  prefix = paste0(type, geoid, "-", "u", user)
  # Check list of existing buckets
  response = googleCloudStorageR::gcs_list_buckets(projectId = project, prefix = prefix, maxResults = max_results)
  # If no buckets exist, this must be the first
  if(is.null(response)){
    latest_order = 0 
    # If any buckets exist, we'll filter them further
  }else{
    # Get the orders
    o = response %>%
      select(name) %>%
      # Filter to just buckets that contain
      # Filter to just buckets that contain your user's id
      filter(str_detect(name, paste0("[-]u", user, "[-]"))) %>%
      # Get the order number 
      mutate(order = str_remove(name, ".*[-]u[0-9]+[-]o"),
             # If there are any extra metadata after the order id (eg. run -r2020), remove it.
             order = str_remove(order, "[-].*"),
             order = as.integer(order))

    if(nrow(o) == 0){
      latest_order = 0
    }else{
      # Get the max order number used to date for that user
      latest_order = o %>%
        summarize(order = max(order)) %>%
        with(order)
    }
  }
  # This order should be the latest_order + 1
  this_order = latest_order + 1
  # Construct new bucket name
  new_bucket_name = paste0(prefix, "-o", this_order)
  return(new_bucket_name)
}




#' @name drop_bucket
#' @title Drop Bucket
#' @description
#' META-function to remove all elements from a bucket and then drop it.
#' @param bucket name of bucket eg. "d36109-u1-o12"
#' @param project "projectname"
#' @param key_path path to API key for authentification
#'
#' @export
drop_bucket = function(bucket = "d36109-u1-o12", project = "projectname",key_path = "raunapikey.json"){
  
  # Testing Values
  # bucket = "d36109-u1-o12"; key_path = "raunapikey.json"
  
  # require(dplyr)
  # require(httr)
  # require(jsonlite)
  # require(gargle)
  # require(googleCloudStorageR)
  # require(purrr)
  # require(readr)
  
  # Authenticate 
  # Get an authorization token
  auth = authorize(key_path = key_path)
  
  
  # Take dtablename - this will be the name of the folder for upload too
  # Get bucket name
  bucket = paste0(project, "-", dtablename_gc)
  
  ## LIST OBJECTS
  response = object_list(bucket = bucket, token = auth$credentials$access_token)
  items = read_api(response)$items
  
  ## DELETE OBJECTS
  for(i in items$name){
    object_delete(file = i, bucket = bucket, token = auth$credentials$access_token)
  }
  cat("\nBucket contents deleted...\n")
  ## DELETE BUCKET
  bucket_delete(bucket = bucket, recursive = TRUE, token = auth$credentials$access_token)
  cat("\nBucket deleted.\n")
  
}



#' @name workflow_execute
#' @title Execute Workflow
#' @author Tim Fraser
#' @description
#' Primarily used to publish tables from `granddata` to `orderdata`, for Cornell CATCLOUD developers.
#' `body` should be a list, matching this structure:
#' `list(fromdbname = "orderdata", fromdbtable = "d36109_u1_o18", todbname = "granddata", todbtable =  "dZZZZZ")`
#' @importFrom httr add_headers POST
#' @importFrom jsonlite toJSON
#' @importFrom dplyr `%>%`
#' @export
workflow_execute = function(workflow_name, body, project= "moves-runs", region = "us-central1", token){
  # Testing Values
  # workflow_name = "orderdata-to-granddata"; 
  # project = "moves-runs"; region = "us-central1"; token = auth$credentials$access_token;
  # key_path = "image_transfer/secret/runapikey.json"
  # auth = catr::authorize(key_path = key_path)
  # body = list(fromdbname = "orderdata", fromdbtable = "d36109_u1_o18", todbname = "granddata", todbtable =  "dZZZZZ")
  
  # require(httr)
  # require(jsonlite)
  # require(dplyr)
  
  # Make URL
  url = paste0("https://workflowexecutions.googleapis.com/v1/projects/", project, "/locations/", region, "/workflows/", workflow_name, "/executions")
  
  # Make authorization header
  headers = add_headers(
    "Authorization" = paste("Bearer ", token),
    "Content-Type" = "application/json; charset = utf-8"
  )
  
  body = body %>%
    toJSON(auto_unbox = TRUE) %>% as.character() %>%
    list(argument = .)
  
  
  response = POST(url = url, body = body, encode = "json", headers)
  
  check_response(response)
  return(response)
  
}




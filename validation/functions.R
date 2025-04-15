# functions.R

# R script of background functions for our validation procedure.

library(dplyr)
library(readr)
library(httr)
library(jsonlite)
library(purrr)
library(stringr)

app_new_order = function(
    geoid, year, user, zipfile = NULL, 
    key = "secret/app-query-analyzer-api-key.json"
){
  
  # Test values
  # geoid = input$geoid; year = input$year; user = auth$cat$userid; zipfile = NULL; key = "secret/app-query-analyzer-api-key.json"
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), 
                          "Content-Type" = "multipart/form-data",
                          "Accept" = "application/json"))
  
  if(!is.null(zipfile)){
    body = list(upload = curl::form_file(path = zipfile, type = "application/x-zip-compressed") )
  }else if(is.null(zipfile)){
    body = list()
  }  
  
  response = POST(
    url = paste0(Sys.getenv("API_PROXY"), "/bucket-trigger-run-upload"),
    query = list(
      geoid = geoid,
      year = year,
      user = user,
      run = 0,
      keepdtable = TRUE,
      location = "us-central1"
    ),
    body = body,
    headers
  )
  
  # if(response$status_code == 200){
  #   output = jsonlite::fromJSON(content(response, type = "text", encoding = "UTF-8"))
  # }else{
  #   output = NULL
  # }
  # 
  output = jsonlite::fromJSON(content(response, type = "text", encoding = "UTF-8"))
  
  return(output)
  
}



check_file_upload = function(files){
  
  # If files is NULL, that means that no files were uploaded, and we should just return NULL
  if(is.null(files)){ 
    output = list(proceed = TRUE, zipfile = NULL)  
    return(output)
  }
  
  
  # extract a data.frame of all files' metadata,
  # with 1 row per file, and columns name, size, type, and datapath
  files$ext = tools::file_ext(files$datapath)
  
  # If it's a length 1 zipfile, proceed
  if(length(files$datapath == 1) & all(files$ext == "zip") ){
    proceed = TRUE
    zipfile = files$datapath[1]
    # Or if there are 1 or more files, ALL csvs
  }else if(length(files$datapath) > 0 & all(files$ext == "csv") ){
    proceed = TRUE
    # Create a zipfile from the various csv files
    zipfile = convert_csv_to_zip(file = files$datapath)
    
    # Or if there is 1 xlsx file
  }else if(length(files$datapath) == 1 & all(files$ext == "xlsx") ){
    proceed = TRUE
    # Create a zipfile from the xlsx sheets
    zipfile = convert_excel_to_zip(file = files$datapath[1])
    
    # Otherwise, invalid upload
  }else{
    proceed = FALSE; 
  }
  
  output = list(proceed = proceed, zipfile = zipfile)
  return(output)
}


#' @name convert_csvs_to_zip
#' @param file:[str] vector of file paths ending in `.csv`
convert_csv_to_zip = function(file){
  
  library(readr)
  original = file
  # For each csv, extract the name of the sheet.
  sheets = tibble(
    original = original,
    name = stringr::str_extract("stuff/stuff/word.csv", pattern = "(?<=/)[^/]+(?=\\.csv)"),
    path = file
  ) 
  
  # Are all files allowable?
  availablefiles = c(
    "monthvmtfraction",
    "dayvmtfraction",
    "hourvmtfraction",
    "sourcetypeyearvmt",
    "sourcetypedayvmt",
    "sourcetypeyear",
    "avft",
    "fuelsupply",
    "fuelusagefraction",
    "fuelformulation",
    "avgspeeddistribution",
    "sourcetypeagedistribution",
    "roadtypedistribution",
    "imcoverage",
    "zonemonthhour",
    "startshourfraction",
    "starts",
    "startsperday",
    "startsperdaypervehicle",
    "startsmonthadjust",
    "startsageadjustment",
    "startsopmodedistribution",
    "hotellingactivitydistribution",
    "hotellinghours",
    "hotellinghourfraction",
    "hotellingagefraction",
    "hotellingmonthadjust",
    "totalidlefraction",
    "idlemodelyeargrouping",
    "idlemonthadjust",
    "idledayadjust",
    "onroadretrofit"
  )
  
  # Filter the files provided to just those that are valid names
  sheets = sheets %>%
    filter(name %in% availablefiles)
  
  # Make a temporary file to be a zipfile
  zippath = tempfile(pattern = "upload", fileext = ".zip")
  
  # Zip files
  zip::zip(zipfile = zippath, files = c(sheets$path), mode = "cherry-pick")
  
  return(zippath)
  
}


convert_excel_to_zip = function(file){
  # Testing value
  # file = "testdata/36119_2021_MOVES_inputs.xlsx"
  
  library(readxl)
  # Get names of all sheets
  original = readxl::excel_sheets(file)
  # For each sheet, 
  sheets = tibble(
    original = original,
    name = tolower(original),
    path = paste0(tempdir(), "\\", name, ".csv")
  )
  
  
  # Are all files allowable?
  availablefiles = c(
    "monthvmtfraction",
    "dayvmtfraction",
    "hourvmtfraction",
    "sourcetypeyearvmt",
    "sourcetypedayvmt",
    "sourcetypeyear",
    "avft",
    "fuelsupply",
    "fuelusagefraction",
    "fuelformulation",
    "avgspeeddistribution",
    "sourcetypeagedistribution",
    "roadtypedistribution",
    "imcoverage",
    "zonemonthhour",
    "startshourfraction",
    "starts",
    "startsperday",
    "startsperdaypervehicle",
    "startsmonthadjust",
    "startsageadjustment",
    "startsopmodedistribution",
    "hotellingactivitydistribution",
    "hotellinghours",
    "hotellinghourfraction",
    "hotellingagefraction",
    "hotellingmonthadjust",
    "totalidlefraction",
    "idlemodelyeargrouping",
    "idlemonthadjust",
    "idledayadjust",
    "onroadretrofit"
  )
  
  # Filter the files provided to just those that are valid names
  sheets = sheets %>%
    filter(name %in% availablefiles)
  
  # Extract csvs for each
  1:length(sheets$original) %>% 
    purrr::walk(
      .f = ~readxl::read_excel(
        path = file,
        sheet = sheets$original[.x]
      ) %>%
        write_csv(file = sheets$path[.x])
    )
  
  # read_csv(sheets$path[3])
  
  # readxl::read_excel(path = file, sheet= sheets$original[i]) %>%
  #   write_csv(file = sheets$path[i])
  
  zippath = tempfile(pattern = "upload", fileext = ".zip")
  
  # Zip files
  zip::zip(zipfile = zippath, files = c(sheets$path), mode = "cherry-pick")
  
  # View contents
  #zip::zip_list(zipfile = zippath)
  
  # Return path to zipfile
  return(zippath)
  
}


# functions ######################################################
#' @name authorize
#' @title Authenticate with Google Cloud using an API key json
#' @param key_path path to API key .json file
#' @param scopes:[str] vector of character scopes, optionally provided. Otherwise defaults to cloud-platform scope
#' @importFrom gargle credentials_service_account
#' @importFrom googleAuthR gar_auth
#' @returns A list object containing service account credentials.
#' @export
authorize = function(key_path, scopes = NULL){
  
  if(is.null(scopes)){
    scopes = "https://www.googleapis.com/auth/cloud-platform"
  }
  
  # Get an authorization token
  auth = gargle::credentials_service_account(
    path = key_path,
    scopes = scopes)
  
  ## Authorize using token
  googleAuthR::gar_auth(token = auth)
  
  return(auth)
}




app_firebase_login = function(email, password){
  
  authEmail = email
  authPassword = password
  response = POST(
    url = paste0(
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword",
      "?key=", 
      Sys.getenv("FIREBASE_API_KEY") ),
    body = list(
      email = toString(authEmail),
      password = toString(authPassword),
      returnSecureToken = TRUE
    ),
    encode = "json"
  )
  
  status = http_status(response)$category
  body = content(response, "text")
  
  # If successful and a valid idToken is received...
  if(status == 'Success' && gregexpr(pattern = '"idToken"', text = body) > 0) {
    # View result
    output = jsonlite::fromJSON(body)
  }else{
    output = NULL
  }
  return(output)
}


app_userid_get = function(firebaseid, key = "secret/app-query-analyzer-api-key.json"){
  # Testing values
  # key = "secret/app-query-analyzer-api-key.json"
  # firebaseid = auth$firebase$localId
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), "Content-Type" = "application/json"))
  response = GET(
    url = paste0(
      Sys.getenv("API_PROXY"), "/userdb-get-userid",
      "?firebaseid=", firebaseid),
    headers,
    encode = "json"
  )
  # If it works
  if(response$status_code == 200){
    output = jsonlite::fromJSON(content(response, type = "text", encoding = "UTF-8"))
    
    # userid will be in a data.frame
    output = as.data.frame(output)
    # check and make sure there is just 1 userid;
    # otherwise, return NULL.
    if(length(output$userid) != 1){ output = NULL  }
    
  }else{
    output = NULL
  }
  return(output)
  
}



#* @param bucket:str name of bucket
app_bucket_object_list = function(bucket, key = "secret/app-query-analyzer-api-key.json"){
  
  bucket = as.character(bucket)
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), 
                          "Content-Type" = "application/json",
                          "Accept" = "application/json"))
  
  response = httr::GET(
    url = paste0(Sys.getenv("API_PROXY"), "/bucket-object-list"),
    query = list(
      bucket = bucket
    ),
    headers,
    encode = "json"
  )
  
  output = content(response, type = "text", encoding = "UTF-8")
  
  # if(response$status_code == 200){
  #   
  #   output = jsonlite::fromJSON(content(response, type = "text", encoding = "UTF-8"))
  # }else{
  #   output = NULL
  # }
  
  return(output)
  
  
}



#* Retrieve a `data.csv` object from a CAT Cloud Storage Bucket
#* @param bucket:str name of bucket
app_bucket_retrieve_data = function(bucket, key = "secret/app-query-analyzer-api-key.json"){
  
  bucket = as.character(bucket)
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), 
                          "Content-Type" = "application/json",
                          "Accept" = "application/json"))
  
  response = httr::GET(
    url = paste0(Sys.getenv("API_PROXY"), "/bucket-retrieve-data"),
    query = list(
      bucket = bucket
    ),
    headers,
    encode = "json"
  )
  
  output = content(response, type = "text", encoding = "UTF-8")
  return(output)
  
  
}


app_bucket_retrieve_movesoutput = function(bucket, key = "secret/app-query-analyzer-api-key.json"){
  
  bucket = as.character(bucket)
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), 
                          "Content-Type" = "application/json",
                          "Accept" = "application/json"))
  
  response = httr::GET(
    url = paste0(Sys.getenv("API_PROXY"), "/bucket-retrieve-movesoutput"),
    query = list(
      bucket = bucket
    ),
    headers,
    encode = "json"
  )
  
  output = content(response, type = "text", encoding = "UTF-8")
  return(output)
  
  
}


jobs_clear = function(njobs = 200, location = "us-central1",  key = "secret/app-query-analyzer-api-key.json"){
  
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  headers = add_headers(c("Authorization" = paste0("Bearer ", token), 
                          "Content-Type" = "application/json",
                          "Accept" = "application/json"))
  
  response = httr::GET(
    url = paste0(Sys.getenv("API_PROXY"), "/job-clear"),
    query = list(
      njobs = njobs,
      location = location
    ),
    headers,
    encode = "json"
  )
  
  output = content(response, type = "text", encoding = "UTF-8")
  
  return(output)
  
}

jobs_list = function(njobs = 100, project = "moves-runs", location = "us-central1", token){
  parent = paste0("projects/", project, "/locations/", location)
  
  base = paste0("https://run.googleapis.com/v2/",parent, "/jobs")
  
  
  url = paste0(base, "?pageSize=", njobs)
  
  
  headers = add_headers(Authorization = paste("Bearer ", token),
                        `Content-Type` = "application/json")
  response = GET(url = url, encode = "json", headers)
  
  output = content(response)
  return(output)
}


bucket_list = function(prefix = "d36", nmax = 100, key = "secret/proxy_api_key.json"){
  
  # Authorize
  auth = authorize(key_path = key)
  token = auth$credentials$access_token
  
  headers = add_headers(Authorization = paste("Bearer ", token),
                        `Content-Type` = "application/json")
  
  response = httr::GET(
    url = "https://storage.googleapis.com/storage/v1/b",
    query = list(
      maxResults = nmax, 
      project = "moves-runs",
      prefix = prefix
      ),
    headers, 
    encode = "json"
  )
  
  result = content(response)
  return(result)
            
  
}

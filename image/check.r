#' @name check.r
#' @author Tim Fraser
#' @description
#' Prints a preview of the uploaded database table if able.
#'
#' @param parameters path to `parameters.json` file
#' @param env path to environmental variables
#' 
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr tibble `%>%` tbl
#' @importFrom DBI dbConnect dbDisconnect dbListTables
#' @importFrom RMySQL MySQL
#' 
#' @export
check = function(parameters = "inputs/parameters.json", env = ".Renviron"){
  
  # Testing values
  # parameters = "inputs/parameters.json"; env = ".Renviron"
  
  # Load packages
  library(DBI)
  library(RMySQL)
  library(dplyr)
  
  # Get the parameters object
  p = jsonlite::fromJSON(parameters)
  
  # Read environmental variables
  readRenviron(path = env)
  
  # Print out the credentials (to help diagnose connection problems)
  paste(
    "---ORDERDATA CREDENTIALS---------------------------",
    paste0("ORDERDATA_USERNAME: ", Sys.getenv("ORDERDATA_USERNAME")),
    paste0("ORDERDATA_PASSWORD:  **************************"),
    paste0("ORDERDATA_HOST: ", Sys.getenv("ORDERDATA_HOST")),
    paste0("ORDERDATA_PORT: ", Sys.getenv("ORDERDATA_PORT")),
    "---------------------------------------------------",
    sep = "\n"
  ) %>%
    cat()
  
  # Connect to orderdata database
  # Load supplementary Packages
  db = DBI::dbConnect(
    drv = RMySQL::MySQL(),
    username = Sys.getenv("ORDERDATA_USERNAME"),
    password = Sys.getenv("ORDERDATA_PASSWORD"),
    host = Sys.getenv("ORDERDATA_HOST"),
    port = as.integer(Sys.getenv("ORDERDATA_PORT")), 
    # Database name (dbname) goes here
    dbname = "orderdata")
  
  # Could alternatively do this, if you have catr.
  # db = catr::connect(type = "mysql", "orderdata")
  
  # View tables
  t = tibble(table = db %>% dbListTables())
  
  # Check if your table is represented there
  condition = any(t$table %in% p$dtablename)
  
  # If your table is present, output a preview
  if(condition == TRUE){
    # Output a preview 
    cat(paste0("\n---table ", p$dtablename, " is present in the database!\n"))
    db %>% tbl(p$dtablename) %>% head()  %>% print()
  }else{
    # Or output a disclaimer.
    cat(paste0("\n---table ", p$dtablename, " is not present in the database.\n"))
  }
  
  # Disconnect from database
  DBI::dbDisconnect(db); remove(db)
  
  # Return the condition
  return(condition)
}

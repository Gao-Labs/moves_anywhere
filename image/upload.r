#' @name upload
#' @title Upload CAT-Formatted Table to CATSERVER
#' @author Tim Fraser
#'
#' @param data (data.frame) data.frame of data to upload
#' @param table (character) table name on CATSERVER to overwrite
#' @param overwrite (logical) overwrite this table? Defaults to TRUE
#' @param append (logical) append this table? Defaults to FALSE
#' 
#' @note `overwrite` and `append` must be opposites 
#' 
#' @importFrom DBI dbConnect dbDisconnect dbWriteTable
#' @importFrom RMySQL MySQL
#' 
#' @export
upload = function(data, table, overwrite = TRUE, append = FALSE){
  
  library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  library(RMySQL, warn.conflicts = FALSE, quietly = TRUE)
  
  # Error Handling
  if( (overwrite == TRUE & append == TRUE) | (overwrite == FALSE & append == FALSE)  ){ 
    stop("`overwrite` and `append` must be opposites. For example, if `overwrite` == TRUE, `append` must == FALSE. If `append` == TRUE, `overwrite` must == FALSE.") 
  }
  
  # Retrieve required values
  username = Sys.getenv("ORDERDATA_USERNAME")
  password = Sys.getenv("ORDERDATA_PASSWORD")
  host = Sys.getenv("ORDERDATA_HOST")
  port = Sys.getenv("ORDERDATA_PORT")
  
  if(nchar(username) == 0){ stop("Need valid username for CATSERVER.") }
  if(nchar(password) == 0){ stop("Need valid password for CATSERVER.") }
  if(nchar(host) == 0){ stop("Need valid host for CATSERVER.") }
  if(nchar(port) == 0){ stop("Need valid port for CATSERVER.") }
  
  # Connect to order database
  db = DBI::dbConnect(
    drv = RMySQL::MySQL(),
    username = username,
    password = password,
    host = host,
    port = as.integer(port),
    dbname = "orderdata"
  )
  
  # Clear
  remove(username, password, host, port)
  # # Check tables
  # db %>% dbListTables()
  # dbDisconnect(db)
  
  fieldtypes = c(
    by = "tinyint(2)",
    year = "smallint(4)",
    geoid = "char(5)",
    pollutant = "tinyint(3)",
    sourcetype = "tinyint(2)",
    regclass = "tinyint(2)",
    fueltype = "tinyint(1)",
    roadtype = "tinyint(1)",
    emissions = "double(18,1)",
    vmt = "double(18,1)",
    sourcehours = "double(18,1)",
    vehicles = "double(18,1)",
    starts = "double(18,1)",
    idlehours = "double(18,1)",
    hoteld = "double(18,1)",
    hotelb = "double(18,1)",
    hotelo = "double(18,1)")
  
  
  # Write a new table using fieldtypes,
  DBI::dbWriteTable(
    # For this database connection
    conn = db,
    # To this table
    name = table,
    # writing this data
    value = data,
    # using these fieldtypes
    field.types = fieldtypes,
    # No rownames field
    row.names = FALSE,
    # NOT appending to existing table
    append = append,
    # OVERWRITING existing table if exists
    overwrite = overwrite)
  
  # Check upload
  # db %>% tbl(table)
  
  # Disconnect
  dbDisconnect(db)
  
  
}
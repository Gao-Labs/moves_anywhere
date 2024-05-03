#' @name upload
#' @title Upload CAT-Formatted Table to CATSERVER
#' @author Tim Fraser
#'
#' @param data (data.frame) data.frame of data to upload
#' @param table (character) table name on CATSERVER to overwrite
#' @param fieldtypes character vector of fieldtypes, from `fieldtypes.r`
#' @param overwrite (logical) overwrite this table? Defaults to TRUE
#' @param append (logical) append this table? Defaults to FALSE
#' 
#' @note `overwrite` and `append` must be opposites 
#' 
#' @importFrom DBI dbConnect dbDisconnect dbWriteTable
#' @importFrom RMySQL MySQL
#' 
#' @export
upload = function(data, table, fieldtypes, overwrite = TRUE, append = FALSE){
  
  library(DBI, warn.conflicts = FALSE, quietly = TRUE)
  library(RMySQL, warn.conflicts = FALSE, quietly = TRUE)
  library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  # Create a value 'end', where if end becomes TRUE, the process stops.
  # By default, end is FALSE, so the process continues.
  end = FALSE
  
  # Error Handling
  if( (overwrite == TRUE & append == TRUE) | (overwrite == FALSE & append == FALSE)  ){
    end = TRUE;
    warning("`overwrite` and `append` must be opposites. For example, if `overwrite` == TRUE, `append` must == FALSE. If `append` == TRUE, `overwrite` must == FALSE.") 
  }
  
  # Retrieve required values
  username = Sys.getenv("ORDERDATA_USERNAME")
  password = Sys.getenv("ORDERDATA_PASSWORD")
  host = Sys.getenv("ORDERDATA_HOST")
  port = Sys.getenv("ORDERDATA_PORT")
  dbname = Sys.getenv("ORDERDATA_DBNAME")
  
  if(nchar(username) == 0){ warning("Need valid username for database."); end = TRUE }
  if(nchar(password) == 0){ warning("Need valid password for database."); end = TRUE }
  if(nchar(host) == 0){ warning("Need valid host for database."); end = TRUE }
  if(nchar(port) == 0){ warning("Need valid port for database."); end = TRUE }
  if(nchar(dbname) == 0){ warning("Need valid dbname for database."); end = TRUE }
  
  # Are all necessary files for ssl cerdentials mounted?
  check_ssl = prod(file.exists(c("secret2/server-ca.pem", "secret3/client-cert.pem", "secret4/client-key.pem")))
  
 
  # Evaluate end
  if(end == FALSE){
    
    # If ssl credentials are provided, use these credentials to connect.
    if(check_ssl == TRUE){
      # Check if there is are .pem files mounted
      db = DBI::dbConnect(
        drv = RMySQL::MySQL(), 
        user = username, 
        password = password, 
        host = host, 
        port = as.integer(port),
        dbname = dbname,
        sslca = "secret2/server-ca.pem",
        sslcert = "secret3/client-cert.pem",
        sslkey = "secret4/client-key.pem")
      # Otherwise, connect the normal way
    }else if(check_ssl == FALSE){
      
      
      # Connect to order database
      db = DBI::dbConnect(
        drv = RMySQL::MySQL(),
        username = username,
        password = password,
        host = host,
        port = as.integer(port),
        dbname = dbname
      )
      
    }
    
    # Clear
    remove(username, password, host, port, dbname)
    # # Check tables
    # db %>% dbListTables()
    # dbDisconnect(db)
    

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
    
    cat(paste0("\n---uploaded to CATSERVER at table ", table, "\n"))
    
  }
  
}
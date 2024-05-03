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
  username = Sys.getenv("USERNAME")
  password = Sys.getenv("PASSWORD")
  host = Sys.getenv("HOST")
  port = Sys.getenv("PORT")
  dbname = Sys.getenv("DBNAME")
  
  if(nchar(username) == 0){ warning("Need valid username for database."); end = TRUE }
  if(nchar(password) == 0){ warning("Need valid password for database."); end = TRUE }
  if(nchar(host) == 0){ warning("Need valid host for database."); end = TRUE }
  if(nchar(port) == 0){ warning("Need valid port for database."); end = TRUE }
  if(nchar(dbname) == 0){ warning("Need valid dbname for database."); end = TRUE }
  
  # Evaluate end
  if(end == FALSE){
    
    # Check if there is are .pem files mounted
    db = DBI::dbConnect(
      drv = RMySQL::MySQL(), 
      user = username, 
      password = password, 
      host = host, 
      port = as.integer(port),
      dbname = dbname)
    # Clear
    remove(username, password, host, port, dbname)
    

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
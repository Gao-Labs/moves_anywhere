#' @name connect
#' @title Connect to Database
connect = function(type = "mariadb", ...){
  
  if(type == "mariadb"){
    # Extract these key values from environmental variables
    username = Sys.getenv("MDB_USERNAME")
    password = Sys.getenv("MDB_PASSWORD")
    port = Sys.getenv("MDB_PORT")
    host = Sys.getenv("MDB_HOST")
    # If they are not specified, 
    # use the default moves database connection info 
    if(nchar(username) == 0){ username = "moves" }
    if(nchar(password) == 0){ password = "moves" }
    if(nchar(port) == 0){ port = 3306 }
    if(nchar(host) == 0){ host = "localhost" }
    # Make connection
    conn = DBI::dbConnect(
      drv = RMariaDB::MariaDB(), 
      username = username, 
      password = password, 
      port = as.integer(port), 
      host = host, 
      dbname = ...)
    # Return connection object
    return(conn)
    
    # If it's a MySQL connection
  }else if(type == "mysql"){
    
    # Extract the input
    values = list(...)
    
    # If there's any values,
    if(length(values) > 0){
      
      # If either there's just one value
      if(length(values) == 1){
        # Get the name of the database we want to connect to
        dbname = values[[1]]
        # eg. "greentechdb"
        
        # Depending on the dbname...
        credentials = switch(
          EXPR = dbname,
          # Change the names of the environmental variable credentials desired
          "granddata" = "CATSERVER",
          "cov" = "CATSERVER",
          "geo" = "CATSERVER",
          "greentechdb" = "GREENTECHDB",
          "userdb" = "USERDB",
          "orderdata" = "ORDERDATA",
          # If these default 'moves' connections,
          "moves" = "MOVES",
          "movesdb20240104" = "MOVES")
      }
      # If there are no values
    }else{
      credentials = "MOVES"
    }
    
    
    cred_username = paste0(credentials, "_USERNAME")
    cred_password = paste0(credentials, "_PASSWORD")
    cred_port = paste0(credentials, "_PORT")
    cred_host = paste0(credentials, "_HOST")
    # Extract these key values from environmental variables
    username = Sys.getenv(cred_username)
    password = Sys.getenv(cred_password)
    port = Sys.getenv(cred_port)
    host = Sys.getenv(cred_host)
    
    # Error handling if blank
    if(nchar(username) == 0){ stop(paste0("---username is blank. Update ", cred_username, " in .env.")) }
    if(nchar(password) == 0){ stop(paste0("---password is blank. Update ", cred_password, " in .env.")) }
    if(nchar(port) == 0){ stop(paste0("---port is blank.  Update ", cred_port, " in .env.")) }
    if(nchar(host) == 0){ stop(paste0("---host is blank.  Update ", cred_host, " in .env.")) }
    # Make connection
    conn = DBI::dbConnect(
      drv = RMySQL::MySQL(), 
      username = username, 
      password = password, 
      port = as.integer(port), 
      host = host, 
      dbname = ...)
    # Return connection object
    return(conn)
  }else{
    # Otherwise, return an errors
    stop("---'type' is not valid. Must be 'mariadb' or 'mysql'.")
  }
}

setwd(rstudioapi::getActiveProject())
setwd("image_upload")
readRenviron(".Renvironcatcloud")

library(dplyr)
library(DBI)
library(RMySQL)
setwd("../../catrplus/movesrunner")
getwd()
db = dbConnect(
  drv = RMySQL::MySQL(),
  username = Sys.getenv("ORDERDATA_USERNAME"),
  password = Sys.getenv("ORDERDATA_PASSWORD"),
  host = Sys.getenv("ORDERDATA_HOST"),
  port = as.integer(Sys.getenv("ORDERDATA_PORT")),
  dbname = "orderdata",
  sslca = "server-ca.pem",
  sslcert = "client-cert.pem",
  sslkey = "client-key.pem"
)


db %>% dbWriteTable(name = "test", value = tibble(x = "hello"), overwrite = TRUE, append = FALSE)
db %>% tbl("test")

dbDisconnect(db)
rm(list = ls())

# task_local_test.R

# Script for accessing a local MariaDB MOVES output database
library(dplyr)
library(dbplyr)
library(readr)
library(catr)
library(DBI)
library(RMariaDB)

# Set directory
setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))
rs = catr::translate_rs(.runspec = "rs_template_M5mar18.xml")

rs$inputdbname

# .env
Sys.setenv("OUTPUTDBNAME"=rs$outputdbname)
Sys.setenv("INPUTDBNAME"="movesdb20240104")
Sys.setenv(MDB_USERNAME="moves")
Sys.setenv(MDB_PASSWORD="moves")
Sys.setenv(MDB_PORT="3306")
Sys.setenv(MDB_HOST="localhost")
Sys.setenv(MDB_DEFAULT="movesdb20240104")
Sys.setenv(MOVES_FOLDER="/EPA_MOVES_Model")
Sys.setenv(TEMP_FOLDER=".")


db = dbConnect(
  drv = RMariaDB::MariaDB(),
  username = "moves",
  password = "moves",
  port = as.integer(1235),
  localhost = 'localhost'
)

db %>% dbListObjects()
db %>% 
  tbl(in_schema("moves", "movesoutput")) %>%
  filter(pollutantID == 98) %>%
  select(emissions = emissionQuant) %>%
  summarize(emissions = sum(emissions, na.rm = TRUE))


db %>% 
  tbl(in_schema("moves", "movesactivityoutput")) %>%
  filter(activityTypeID == 6) %>%
  summarize(activity = sum(activity, na.rm = TRUE)) 


dbDisconnect(db)

# task_test_db.R

library(dplyr)
library(dbplyr)
library(readr)
library(catr)
library(DBI)
library(RMariaDB)

db = catr::connect("mariadb", "movesdb20241112")
dbDisconnect(db)

db = catr::connect("mariadb", "custom")
db %>% tbl("hourvmtfraction") %>%  select(sourceTypeID)  %>% distinct() %>% count()

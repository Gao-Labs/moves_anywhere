# queries_default.R

# Finally, we demonstrate MOVES Anywhere
# by using it to run a simply ridiculous number of jobs.
# We're going to kick off the jobs now.

# Set working directory
setwd(paste0(rstudioapi::getActiveProject(), "/validation"))

library(dplyr)
library(readr)
library(purrr)
library(httr)
library(readxl)
library(googleAuthR)

# Load functions
source("functions.R")
# Load environmental variables
readRenviron("secret/.env")


# Scenario 15: Defaults for Many Counties #################################


# Login 
auth = app_firebase_login(email = Sys.getenv("CAT_USERNAME"), password = Sys.getenv("CAT_PASSWORD"))
auth$cat = app_userid_get(firebaseid = auth$localId)
auth$cat

# files = dir("data", full.names = TRUE)
scenario = 17
# Get all the 
mygeoids = read_rds("../moves_anywhere/scripts/geoids.rds") %>%
  filter(state %in% c("NY"))
# Estimate emissions for 2025
myyear = 2025

for(i in 1:length(mygeoids$geoid)){
  
  geoid = mygeoids$geoid[i]
  
  result = app_new_order(user = auth$cat$userid, geoid = geoid, year = myyear, zipfile = NULL)
  # result %>% as_tibble() %>% mutate(file = files[i]) %>% slice(0) %>% write_csv("runs.csv")
  # Append the result to our file
  result %>% as_tibble() %>% 
    mutate(file = NA) %>% 
    mutate(scenario = scenario) %>%
    write_csv("runs.csv", append = TRUE)
  
  cat(paste0("\n---", i, " completed: ", geoid, "\n"))
}


# DOWNLOADS
# runs = read_csv("runs.csv") %>%
#   filter(scenario %in% c(17))

mygeoids = read_rds("../moves_anywhere/scripts/geoids.rds") %>%
  filter(state %in% c("NY"))

# data = bucket_list(prefix = "d36", nmax = 100) %>%
#   with(items) %>%
#   purrr::map_dfr(~tibble(bucket = .x$id, time = .x$timeCreated) ) %>%
#   mutate(time = time %>% 
#            lubridate::as_datetime() %>%
#            lubridate::with_tz(tzone = "EST")) %>%
#   arrange(desc(time))


buckets = tribble(
  ~bucketname,
  "d36123-u23-o1",
  "d36121-u23-o1",
  "d36119-u23-o10",
  "d36117-u23-o1",
  "d36115-u23-o1",
  "d36113-u23-o1",
  "d36111-u23-o1",
  "d36109-u23-o215",
  "d36107-u23-o1",
  "d36105-u23-o1",
  "d36103-u23-o1",
  "d36101-u23-o1",
  "d36099-u23-o1",
  "d36097-u23-o1",
  "d36093-u23-o1",
  "d36089-u23-o1",
  "d36087-u23-o10",
  "d36085-u23-o1",
  "d36083-u23-o1",
  "d36079-u23-o1",
  "d36077-u23-o1",
  "d36073-u23-o1",
  "d36071-u23-o1",
  "d36069-u23-o1",
  "d36067-u23-o1",
  "d36065-u23-o1",
  "d36063-u23-o1",
  "d36061-u23-o11",
  "d36059-u23-o11",
  "d36057-u23-o1",
  "d36055-u23-o1",
  "d36053-u23-o1",
  "d36049-u23-o1",
  "d36047-u23-o1",
  "d36045-u23-o1",
  "d36043-u23-o1",
  "d36041-u23-o1",
  "d36039-u23-o1",
  "d36037-u23-o1",
  "d36033-u23-o1",
  "d36029-u23-o1",
  "d36027-u23-o1",
  "d36025-u23-o1",
  "d36023-u23-o1",
  "d36021-u23-o1",
  "d36019-u23-o1",
  "d36017-u23-o1",
  "d36015-u23-o1",
  "d36013-u23-o1",
  "d36011-u23-o1",
  "d36009-u23-o1",
  "d36007-u23-o1",
  "d36005-u23-o21",
  "d36003-u23-o1",
  "d36001-u23-o1"
)

runs = read_csv("runs.csv") %>% filter(scenario == 17)

# gc()
# unlink(tempdir(), recursive = TRUE, force = TRUE)
# Download Results
for(i in 1:nrow(runs)){
  app_bucket_retrieve_data(bucket = runs$bucket[i]) %>%
    write_lines(paste0("outputs_geo/", runs$bucket[i], ".csv"))
  cat(paste0("\n---", i, " completed: ", runs$bucket[i], "\n"))
  
}

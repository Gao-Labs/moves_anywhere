#' @name get_pop
#' @description
#' Script for getting and formatting past and future population data

# get_future ################################

# Load packages
library(dplyr)
library(readr)
library(tidyr)
library(readxl)
library(stringr)
library(purrr)
setwd("translators")
getwd()


# Let's make a single .rda file in catr/data 
# that will contain county-level population projections

# Hauer developed 5 scenarios (SSPs)
# each with their own population projections

# As a safe(r) assumption, 
# let's use SSP2 - "Middle of the Road"
get_data = function(path){
  # Testing Value
  #path = "data_raw/hauer/hauer_county_0_4_pop_SSPs.xlsx"
  
  type = path %>% str_remove(".*county[_]") %>% str_remove("([_]pop|pop)[_]SSPs[.]xlsx")
  
  data = path %>% read_excel()
  
  output = data %>% 
    select(geoid, contains("ssp")) %>%
    pivot_longer(cols = contains("ssp"), names_to = "name", values_to = "pop") %>%
    mutate(year = str_sub(name, -4,-1) %>% as.integer(),
           scenario = str_sub(name, 1,4) %>% str_remove("ssp")) %>%
    # Add in the type of data being shown
    mutate(type = type) %>%
    select(geoid, scenario, type, year, pop)
  
  print(path)
  return(output)
}

"data_raw/hauer_county_totpop_SSPs.xlsx" %>%
  map(~get_data(.)) %>% 
  bind_rows() %>%
  # Drop any non indentified geoids
  filter(!is.na(geoid)) %>%
  pivot_wider(id_cols = c(geoid, scenario, year),
              names_from = type, values_from = pop, names_prefix = "pop_") %>%
  # Set names to lower case
  setNames(nm = tolower(names(.))) %>%
  mutate(type = paste0("ssp", scenario)) %>%
  select(geoid, year, pop = pop_tot, type) %>%
  saveRDS("data_raw/pop_future.rds")

# get_past ################################
# Script to get data for 1990, 2000, 2010, and 2020 for extraction

#install.packages("ipumsr")
# https://cran.r-project.org/web/packages/ipumsr/vignettes/ipums-api-nhgis.html
library(ipumsr)
library(dplyr)
library(purrr)
# Get an IPUMS API Key for free
# https://account.ipums.org/api_keys
readRenviron(".Renviron")
# Set api key
set_ipums_api_key(api_key = Sys.getenv("IPUMS"), save = TRUE)

tst = get_metadata_nhgis("time_series_tables")

myyears = tst %>%
  filter(description == "Total Population") %>%
  filter(name == "AV0") %>%
  with(years) %>%
  .[[1]]  %>%
  filter(!name %in% c("1970", "1980")) %>%
  with(description)


ext = define_extract_nhgis(
  description = "Example population data over time",
  time_series_tables =  tst_spec(
    name = "AV0", geog_levels = "county", 
    years = myyears)
)

# 
# tst %>% 
#   filter(description == 'Total Population',
#          geographic_integration == "Standardized to 2010") %>%
#   with(geog_levels)
# tst %>% 
#   filter(description == 'Total Population',
#          geographic_integration == "Standardized to 2010")  %>%
#   with(years)
# 
# ext = define_extract_nhgis(
#   description = "Example population data in 1990",
#   time_series_tables =  tst_spec(
#     name = "CL8", geog_levels = "county", 
#     years = c("1990", "2000", "2010", "2020"))
# )
# Submit the request
submitted = submit_extract(extract = ext)
# Wait
downloadable = wait_for_extract(submitted)
# Download it
data_files = download_extract(downloadable)

# downloaded to nhgis0007_csv.zip
rm(list = ls())

# make_past ################################

#' @name make_historical.R
#' @description
#' Processing Historical Population Data

library(dplyr)
library(readr)
library(tidyr)
library(stringr)

getwd()
setwd(rstudioapi::getActiveProject())
setwd("catr")
getwd()
# Unzip this file
unzip("data_raw/nhgis0007_csv.zip", junkpaths = TRUE, exdir = "data_raw")

path = "data_raw/nhgis0007_ts_nominal_county.csv"

metadata = tribble(
  ~name, ~description, ~sequence, ~year, ~type,
  '1990', "1990", 108, 1990, "dec",
  '2000', "2000", 118, 2000, "dec",
  '105', "2006-2010", 133, 2008, "acs5",
  '115', "2007-2011", 136, 2009, "acs5",
  '2010', "2010", 131, 2010, "dec",
  #'125', "2008-2012", 139, 2010, "acs5",
  '135', "2009-2013", 142, 2011,  "acs5",
  '145', "2010-2014", 144, 2012, "acs5",
  '155', "2011-2015", 146, 2013, "acs5",
  '165', "2012-2016", 148, 2014, "acs5",
  '175', "2013-2017", 150, 2015, "acs5",
  '185', "2014-2018", 152, 2016, "acs5",
  '195', "2015-2019", 154, 2017, "acs5",
  '205', "2016-2020", 156, 2018, "acs5",
  '215', "2017-2021", 158, 2019, "acs5",
  '225', "2018-2022", 160, 2020, "acs5",
  '2020', "2020", 155, 2020, "dec"
) %>%
  # Prioritize decennial census when available
  filter(!description %in% c("2008-2012", "2018-2022")) %>%
  mutate(year = as.integer(year))

path %>% 
  read_csv() %>%
  select(fips_state = STATEFP, fips_county = COUNTYFP, contains("AV0AA")) %>%
  mutate(geoid = paste0(fips_state, fips_county)) %>%
  select(-fips_state, -fips_county) %>%
  pivot_longer(cols = contains("AV0AA"), names_to = "name", values_to = "pop")  %>%
  mutate(type = case_when(str_detect(name, "M") ~ "pop_moe", TRUE ~ "pop")) %>%
  mutate(name = name %>% str_remove("AV0AA") %>% str_remove("M")) %>%
  pivot_wider(id_cols = c(geoid, name), names_from = type, values_from = pop ) %>%
  inner_join(by = "name", y = metadata %>% select(name, year, type)) %>%
  select(geoid, year, type, pop) %>%
  arrange(geoid, year) %>%
  saveRDS("data_raw/pop_past.rds")


# make_pop ####################################

# Bundle these together

# Get population from 2020 - 210
bind_rows(
  # Acquire Future data from scenario 2 (business as usual)
  read_rds("data_raw/pop_future.rds") %>%
    filter(type == "ssp2") %>%
    filter(year > 2020),
  # Acquire past data from 1990 to 2020
  read_rds("data_raw/pop_past.rds")
) %>%
  # Keep just the valid records
  filter(!is.na(pop)) %>%
  saveRDS("data_raw/pop_raw.rds")

# interpolate #######################################

  
# Find the geoids tracked in the future
mygeoids = read_rds("data_raw/pop_future.rds") %>%
  select(geoid) %>%
  distinct()

# Get the observations for any geoids that are tracked in the future
# This helps us skip any counties that were discontinued after the 1990 decentennial census.
data = read_rds("data_raw/pop_raw.rds") %>%
  inner_join(by = "geoid", y = mygeoids) 


# Interpolate Projections annually
s_overall = data %>%
  group_by(year) %>%
  summarize(total = sum(pop)) %>%
  reframe(year_range = 1990:2100,
          total = approx(x = year, y = total, xout = year_range)$y) %>%
  rename(year = year_range)

s_county = data %>%
  group_by(geoid) %>%
  reframe(
    year_range = 1990:2100,
    pop = approx(x = year, y = pop, xout = year_range)$y) %>%
  rename(year = year_range)

projections = s_county %>%
  left_join(by = "year", y = s_overall) %>%
  mutate(fraction = pop / total) 
 
save(projections, file = "data/projections.rda")

remove(data, mygeoids, s_county, s_overall)


rm(list = ls())





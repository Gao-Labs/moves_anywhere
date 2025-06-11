# validate_adapt_from_nei.R

# Script to run validation analysis on adapt_from_nei.R script functions.

source("scripts/adapt_from_nei.R")

# Which geoids will not be supported by the get_vmt3 or get_vehicle3 methods?
# tigris::fips_codes %>%
#   mutate(geoid = paste0(state_code, county_code)) %>%
#   anti_join(by = "geoid", y = read_rds("scripts/projections.rds")) %>%
#   write_csv("scripts/geoids_not_supported.csv")

# For this grid of randomly selected counties, run the functions and check that their outputs are not crazy.
grid = read_rds("scripts/projections.rds") %>%
  select(geoid) %>%
  distinct() %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) %>%
  group_by(state) %>%
  sample_n(size = 1, replace = TRUE) %>%
  group_by(state, geoid) %>%
  reframe(year = sample(c(1990, 1999, 2000:2060), size = 1, replace = FALSE) ) %>%
  ungroup() %>%
  mutate(id = 1:n())

check_valid = function(data){
  subset = data

  vmt = purrr::possibly(.f = ~adapt_vmt_from_nei(.geoidchar = subset$geoid, .year = subset$year), otherwise = NULL)()
  if(is.null(vmt)){ n_vmt = 0; m_vmt = Inf }else{ n_vmt = length(vmt$sourceTypeID); m_vmt = sum(is.na(vmt$VMT)) }

  vehicles = purrr::possibly(.f = ~adapt_vehicles_from_nei(.geoidchar = subset$geoid, .year = subset$year), otherwise = NULL)()

  if(is.null(vehicles)){ n_vehicles = 0;  m_vehicles = Inf }else{ n_vehicles = length(vehicles$sourceTypeID); m_vehicles = sum(is.na(vehicles$sourceTypePopulation)) }

  output = tibble(
    id = c(subset$id, subset$id),
    n_rows = c(n_vmt, n_vehicles),
    missing = c(m_vmt, m_vehicles)
  )
  output

}

# get_vmt1(.geoidchar = "02063", .year = 2043)
data = grid %>%
  split(.$id) %>%
  purrr::map_dfr(.f = ~check_valid(data = .x)) %>%
  left_join(by = "id", y = grid)

data

# My error rate is... 0/51
data %>%
  filter(n_rows == 0)

get_vmt1(.geoidchar = "36109", .year = 2019)
get_vmt2(.geoidchar = "36109", .year = 2023, .yearofinterest = 2020)

# Get EXACT NEI data from a specific year WITHIN NEI timeframe
get_vehicles0(.geoidchar = "36109", .year = 2017)

# Interpolate NEI data from a specific year WITHIN NEI timeframe
get_vehicles1(.geoidchar = "36109", .year = 2016)

# We don't need to use get_vehicles0 anymore. It will be more robust to use get_vehicles1.

# Interpolate from the NEI data WITHIN NEI timeframe
get_vehicles1(.geoidchar = "36109", .year = 2011)


# Interpolate from the NEI data WITHIN NEI timeframe
get_vehicles1(.geoidchar = "36109", .year = 2020)

# Interpolate from MOVES OUTSIDE the NEI timeframe
get_vehicles2(.geoidchar = "36109", .year = 2022)

# Interpolate from MOVES OUTSIDE the NEI timeframe
get_vehicles2(.geoidchar = "36109", .year = 2002)

# 2000:2060 %>% purrr::map_dfr(.f = ~adapt_vehicles_from_nei(.geoidchar = "36109", .year = .x)) %>% View()


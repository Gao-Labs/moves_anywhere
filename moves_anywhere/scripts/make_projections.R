# make_projections.rds

# Script to summarize how projections.rds gets made

library(dplyr)
library(readr)
library(tigris)
library(sf)

# Get me the land area of these counties
area = tigris::counties(cb = TRUE, year = 2022) %>%
  select(geoid = GEOID, name = NAME, state = STUSPS, area_land = ALAND, geometry) %>%
  mutate(area_land = area_land / (1e3^2) )

# Calculate each county's population density.
stat = catr::projections %>%
  left_join(
    by = "geoid",
    y = area %>%
      as_tibble() %>%
      select(geoid, area_land)) %>%
  mutate(density = pop / area_land) %>%
  group_by(year) %>%
  mutate(fraction2 = density / sum(density, na.rm = TRUE)) %>%
  ungroup()

stat %>% saveRDS("scripts/projections.rds")


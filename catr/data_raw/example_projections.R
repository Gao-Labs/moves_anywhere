
# Example of applying it

sourcetypeyear = tribble(
  ~yearID, ~sourceTypeID, ~sourceTypePopulation,
  2023,    11,            1500000,
  2023,    21,            1700000,
  2023,    31,            2000000
)

data("projections", package = "catr")
.geoid = "36109"
.year = 2023

# For geoid 36109
estimates = projections %>%
  filter(year == .year & geoid == .geoid)


sourcetypeyear = sourcetypeyear %>%
  left_join(by = c("yearID" = "year"), y = estimates %>% select(year, fraction)) %>%
  mutate(sourceTypePopulation = sourceTypePopulation * fraction) %>%
  select(-fraction)

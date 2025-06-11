# validate_get_vmt3.R

# Validation procedure for our last-ditch-attempt model,
# where if we dont have any prior vmt/vehicle data on that geoid,
# we use a population and area based projection 

library(dplyr)
library(readr)
library(ggplot2)
library(car)
library(broom)

setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))
.geoidchar = "36109"; .year = 2022
path_nei_sourcetypeyearvmt = "scripts/reference/nei_sourcetypeyearvmt.rds"; path_projections = "scripts/projections.rds"
.sourcetypes = c(11,21,31,32,41,42,43,51,52,53,54,61,62)
path_urban = "scripts/reference/urban_areas.rds"

library(sf)
# tigris::urban_areas(cb = TRUE, year = 2020) %>%
#   st_as_sf() %>% st_transform(crs = 4326) %>%
#   select(urban_id = UACE10, geoid = GEOID10, name = NAME10, type = UATYP10, geometry) %>%
#   saveRDS("scripts/reference/urban.rds")
read_rds("scripts/reference/urban.rds") %>%
  as_tibble() %>%
  select(geoid, type) %>%
  mutate(value = 1) %>%
  tidyr::pivot_wider(id_cols = geoid, names_from = type, values_from = value, values_fill = list(value = 0), names_prefix = "type_") %>%
  group_by(geoid) %>%
  summarize(type_c = sum(type_C, na.rm = TRUE),
            type_u = sum(type_U, na.rm = TRUE), .groups = "drop") %>%
  right_join(by = "geoid", x = read_rds("scripts/geoids.rds") %>% select(geoid)) %>%
  mutate(across(any_of(c("type_c", "type_u")), .f = ~if_else(is.na(.x), true = 0, false = .x))) %>%
  saveRDS("scripts/reference/urban_areas.rds")



newdata = read_rds(path_projections) %>%
  filter(geoid == .geoidchar, year == .year) %>%
  select(geoid, year, pop, area_land) %>%
  mutate(state = stringr::str_sub(geoid, 1,2))




get_vif = function(m){
  # testing values    
  # m = lm(hp ~ mpg + cyl, mtcars)
  # m = lm(hp ~ mpg + factor(cyl), mtcars)
  myvif = car::vif(m)
  if(is.matrix(myvif)){
    output = myvif[,3]^2
  }else{ output = myvif }
  return(output)
}

data = read_rds(path_nei_sourcetypeyearvmt) %>%
  left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
  left_join(by = c("geoid"), y = read_rds(path_urban)) %>%
  mutate(across(any_of(c("type_c", "type_u")), .f = ~if_else(is.na(.x), true = 0, false = .x))) %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) %>%
  group_by(sourcetype) %>%
  reframe(
    vif = lm(formula = log(vmt + 1) ~ log(pop + 1) + log(area_land + 1) +
               type_u + type_c +
               year + state) %>% 
      get_vif() %>% max()
  )
# Really great VIF
data


national = tribble(
  ~sourcetype, ~HPMSVtypeID,
  11, 10,
  21, 25,
  31, 25,
  32, 25,
  41, 40,
  42, 40,
  43, 40,
  51, 50,
  52, 50,
  53, 50,
  54, 50,
  61, 60,
  62, 60
) %>%
  left_join(
    by = "HPMSVtypeID",
    y = read_csv("scripts/reference/hpmsvtypeyear.csv", show_col_types = FALSE), 
    relationship = "many-to-many",
    multiple = "all") %>% 
  select(sourcetype, year = yearID, default_hpmsvmt = HPMSBaseYearVMT) %>%
  left_join(
    by = c("year" = "yearID", "sourcetype" = "sourceTypeID"),
    y = read_csv("scripts/reference/sourcetypeyear.csv", show_col_types = FALSE) %>% 
      select(yearID, sourceTypeID, default_vehicles = sourceTypePopulation), 
    relationship = "many-to-many",
    multiple = "all") %>%
  # Calculate rate of vmt per vehicle at a national scale
  mutate(default_rate = default_hpmsvmt / default_vehicles)


newdata = read_rds(path_projections) %>%
  filter(geoid == .geoidchar, year == .year) %>%
  select(geoid, year, pop, area_land) %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) 
  # left_join(by = c("year"), y = national) %>%
  # rename(.sourcetype = sourcetype)

data = read_rds(path_nei_sourcetypeyearvmt) %>%
  # filter to desired sourcetypes
  filter(sourcetype %in% .sourcetypes) %>%
  left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
  left_join(by = c("geoid"), y = read_rds(path_urban)) %>%
  mutate(across(any_of(c("type_c", "type_u")), .f = ~if_else(is.na(.x), true = 0, false = .x))) %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) %>%
  # left_join(by = c("sourcetype", "year"), y = national) %>%
  group_by(sourcetype) %>%
  reframe(
    lm(formula = log(vmt + 1) ~ log(pop + 1) + log(area_land + 1)  + state) %>%
      broom::glance()
      # get_vif() %>% max()
#      predict(newdata = newdata %>% filter(.sourcetype == sourcetype[1]))
  )
data



data %>% filter(vif > 5)
# cor(newdata$default_hpmsvmt, newdata$default_vehicles)

# Check the R-2
read_rds(path_nei_sourcetypeyearvmt) %>%
  left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) %>%
  left_join(by = c("sourcetype", "year"), y = hpms) %>%
  group_by(sourcetype) %>%
  reframe(
    lm(formula = log(vmt + 1) ~ log(pop + 1) + log(area_land + 1) + log(hpmsbaseyearvmt + 1) + year + state) %>% 
      broom::glance()
  ) %>%
  ggplot(mapping = aes(x = factor(sourcetype), y = r.squared)) +
  geom_col() +
  coord_flip()
# respectable r-squared.

data = read_rds(path_nei_sourcetypeyearvmt) %>%
  left_join(by = c("geoid", "year"), y = read_rds(path_projections)) %>%
  mutate(state = stringr::str_sub(geoid, 1,2)) %>%
  group_by(sourcetype) %>%
  reframe(
    {
      m = lm(formula = log(vmt + 1) ~ log(pop + 1) + log(area_land + 1) + year + state)
      sigma = m %>%
        broom::glance() %>%
        with(sigma)
      yhat = quantile(m$fitted.values, probs = c(0.2, 0.5, 0.8))
      tibble(yhat = yhat, sigma = sigma) %>%
        mutate(id = 1:n())
    }
  ) %>%
  group_by(sourcetype, id) %>%
  reframe(
      ysim = (rnorm(n = 1000, mean = yhat, sd = sigma) %>% exp() - 1)
  ) %>%
  group_by(sourcetype, id) %>%
  summarize(
    mu = mean(ysim),
    se = sd(ysim),
    cv = se / mu
  )

rm(list = ls())

  
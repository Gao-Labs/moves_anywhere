# make_nei.R

# Download the NEI MOVES inputs, to use as starting resources for:
# - sourcetypeyear
# - sourcetypeyearvmt

setwd(paste0(rstudioapi::getActiveProject(),"/moves_anywhere"))

library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(purrr)

# National Emissions Inventory data stored here:
# https://gaftp.epa.gov/air/nei/
# On-road data
# https://gaftp.epa.gov/air/nei/2020/doc/supporting_data/onroad/

# https://gaftp.epa.gov/air/nei/2017/doc/supporting_data/onroad/
# https://gaftp.epa.gov/air/nei/2017/doc/supporting_data/onroad/2017NEI_onroad_activity_final.zip

# download.file(url = "https://gaftp.epa.gov/air/nei/2020/doc/supporting_data/onroad/2020NEI_onroad_activity_final_20230112.zip", 
#               destfile = "dev/2020.zip")
# 
# download.file(url = "https://gaftp.epa.gov/air/nei/2017/doc/supporting_data/onroad/2017NEI_onroad_activity_final.zip", 
#               destfile = "dev/2017.zip")
#
#
# download.file(url = "https://gaftp.epa.gov/air/nei/2014/doc/2014v2_supportingdata/onroad/2014v2_onroad_activity_final.zip",
#               destfile = "dev/2014.zip")

# download.file(url = "https://gaftp.epa.gov/air/nei/2011/doc/2011v2_supportingdata/onroad/2011neiv2_supdata_or_VMT.zip",
#               destfile = "2011.zip")

# https://gaftp.epa.gov/air/nei/2011/doc/2011v2_supportingdata/onroad/2011neiv2_supdata_or_VPOP.zip
# Unzip and rename files

# Reformat the SCC codes.
bind_rows(
  readxl::read_excel("dev/SCC.xlsx", sheet = "VMT") %>%
    setNames(nm = str_replace_all(tolower(names(.)), " ", "_" )) %>%
    mutate(type = "VMT"),
  readxl::read_excel("dev/SCC.xlsx", sheet = "HOTELLING") %>%
    setNames(nm = str_replace_all(tolower(names(.)), " ", "_" )) %>%
    mutate(type = "HOTELLING"),
  readxl::read_excel("dev/SCC.xlsx", sheet = "VPOP") %>%
    setNames(nm = str_replace_all(tolower(names(.)), " ", "_" )) %>%
    mutate(type = "VPOP")
) %>%
  write_csv("dev/SCC.csv")

# FORMAT ###########################

## VMT #######################

headers = read_csv("dev/VMT_2020NEI.csv", n_max = 13) %>% slice(12) %>% str_split(pattern = ",") %>% unlist() %>% str_remove("# ")
data = read_csv(
  file = "dev/VMT_2020NEI.csv", skip = 16, 
  col_names = headers, 
  col_select = c(
    "geoid" = 2,
    "scc" = 6,
    "vmt" = 10, # annual vmt
    "year" = 11
    #                  "jan_value" = 14,
    #                  "feb_value" = 15,
    #                  "mar_value" = 16,
    #                  "apr_value" = 17,
    #                  "may_value" = 18,
    #                  "jun_value" = 19,
    #                  "jul_value" = 20,
    #                  "aug_value" = 21, 
    #                  "sep_value" = 22,
    #                  "oct_value" = 23,
    #                  "nov_value" = 24,
    #                  "dec_value" = 25)
    # n_max = 25
  )
)

saveRDS(data, file = "dev/VMT.rds")

headers = read_csv("dev/VMT_2017NEI.csv", n_max = 13) %>% slice(12) %>% str_split(pattern = ",") %>% unlist() %>% str_remove("# ")

data = read_csv(
  file = "dev/VMT_2017NEI.csv", 
  skip = 17, n_max = 25,
  col_names = headers,
  col_select = c(
    "geoid" = 2,
    "scc" = 6,
    "vmt" = 10,
    "year" = 11
  )
)

read_rds("dev/VMT.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VMT.rds")



data = read_csv(
  file = "dev/VMT_2014NEI.csv",
  col_select = c(
    "geoid" = 1,
    "scc" = 2,
    "vmt" = 4,
    "year" = 5
  )
)

read_rds("dev/VMT.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VMT.rds")

data = read_csv(
  file = "dev/VMT_2011NEI.csv",
  col_select = c(
    "geoid" = 1,
    "scc" = 2,
    "vmt" = 4,
    "year" = 5
  )
)

read_rds("dev/VMT.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VMT.rds")

remove(data, headers)

## VPOP #####################################

headers = read_csv("dev/VPOP_2020NEI.csv", n_max = 21) %>% slice(21) %>% str_split(pattern = ",") %>% unlist() %>% str_remove("# ")

data = read_csv(
  file = "dev/VPOP_2020NEI.csv", skip = 27, 
  col_names = headers,
  col_select = c(
    "geoid" = 2,
    "scc" = 6,
    "vehicles" = 10, # annual vmt
    "year" = 11
    #                  "jan_value" = 14,
    #                  "feb_value" = 15,
    #                  "mar_value" = 16,
    #                  "apr_value" = 17,
    #                  "may_value" = 18,
    #                  "jun_value" = 19,
    #                  "jul_value" = 20,
    #                  "aug_value" = 21, 
    #                  "sep_value" = 22,
    #                  "oct_value" = 23,
    #                  "nov_value" = 24,
    #                  "dec_value" = 25)
    # n_max = 25
  )
)

data %>% saveRDS("dev/VPOP.rds")



headers = read_csv("dev/VPOP_2017NEI.csv", n_max = 6) %>% slice(6) %>% str_split(pattern = ",") %>% unlist() %>% str_remove("# ")

data = read_csv(
  file = "dev/VPOP_2017NEI.csv", skip = 18, 
  col_names = headers,
  col_select = c(
    "geoid" = 2,
    "scc" = 6,
    "vehicles" = 10, # annual vmt
    "year" = 11
    #                  "jan_value" = 14,
    #                  "feb_value" = 15,
    #                  "mar_value" = 16,
    #                  "apr_value" = 17,
    #                  "may_value" = 18,
    #                  "jun_value" = 19,
    #                  "jul_value" = 20,
    #                  "aug_value" = 21, 
    #                  "sep_value" = 22,
    #                  "oct_value" = 23,
    #                  "nov_value" = 24,
    #                  "dec_value" = 25)
    # n_max = 25
  )
)

read_rds("dev/VPOP.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VPOP.rds")


data = read_csv(
  file = "dev/VPOP_2014NEI.csv", 
  col_select = c(
    "geoid" = 1,
    "scc" = 2,
    "vehicles" = 3,
    "year" = 4)
)


read_rds("dev/VPOP.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VPOP.rds")

data = read_csv(
  file = "dev/VPOP_2011NEI.csv", 
  col_select = c(
    "geoid" = 1,
    "scc" = 2,
    "vehicles" = 4,
    "year" = 5)
  )

read_rds("dev/VPOP.rds") %>%
  bind_rows(data) %>%
  saveRDS("dev/VPOP.rds")

remove(data, headers)





# CONVERT ###########################################

## VMT #####################################
# scc = read_csv("dev/SCC.csv") %>%
#   filter(type == "VMT") %>%
#   mutate(sourcetype = vehicle_type %>% dplyr::recode(
#     "Motorcycles" = 11,
#     "Passenger Cars" = 21,
#     "Passenger Trucks" = 31,
#     "Light Commercial Trucks" = 32,
#     "Other Buses" = 41,
#     "Intercity Buses" = 41,
#     "Transit Buses" = 42,
#     "School Buses" = 43,
#     "Refuse Trucks" = 51,
#     "Single Unit Short-haul Trucks" = 52,
#     "Single Unit Long-haul Trucks" = 53,
#     "Motor Homes" = 54,
#     "Combination Short-haul Trucks" = 61,
#     "Combination Long-haul Trucks" = 62
#   ),
#   roadtype = road_type %>% dplyr::recode(
#     "Off-Network" = 1,
#     "Rural Restricted Access" = 2,
#     "Rural Unrestricted Access" = 3,
#     "Urban Restricted Access" = 4, 
#     "Urban Unrestricted Access" = 5
#   )
#   ) %>%
#   select(scc, sourcetype, roadtype)
# scc %>% View()
# scc$roadtype %>% unique()

# Template sourcetypeyearvmt
read_rds("dev/VMT.rds") %>%
  mutate(sourcetype = str_sub(scc, 5,6) %>% as.integer()) %>%
  # left_join(by = "scc", y = scc)  %>%
  group_by(geoid, sourcetype, year) %>%
  summarize(vmt = sum(vmt, na.rm = TRUE), .groups = "drop") %>%
  saveRDS("dev/nei_sourcetypeyearvmt.rds")


# Template roadtypedistribution
read_rds("dev/VMT.rds") %>%
#  left_join(by = "scc", y = scc)  %>%
  mutate(sourcetype = str_sub(scc, 5,6) %>% as.integer()) %>%
  mutate(roadtype = str_sub(scc, 7,8) %>% as.integer()) %>%
  group_by(geoid, sourcetype, roadtype, year) %>%
  summarize(vmt = sum(vmt, na.rm = TRUE), .groups = "drop") %>%
  saveRDS("dev/nei_vmt_by_sourcetype_roadtype.rds")


# group_by(geoid, year, sourcetype) %>%
# mutate(vmt = vmt / sum(vmt, na.rm = TRUE)) %>%
# ungroup() %>%
# saveRDS("dev/roadtypedistribution_nei.rds")

rm(list = ls())

## VPOP ###############################

# scc = read_csv("dev/SCC.csv") %>%
#   #filter(type == "VPOP" | type == "VMT") %>%
#   mutate(sourcetype = vehicle_type %>% dplyr::recode(
#     "Motorcycles" = 11,
#     "Passenger Cars" = 21,
#     "Passenger Trucks" = 31,
#     "Light Commercial Trucks" = 32,
#     "Other Buses" = 41,
#     "Intercity Buses" = 41,
#     "Transit Buses" = 42,
#     "School Buses" = 43,
#     "Refuse Trucks" = 51,
#     "Single Unit Short-haul Trucks" = 52,
#     "Single Unit Long-haul Trucks" = 53,
#     "Motor Homes" = 54,
#     "Combination Short-haul Trucks" = 61,
#     "Combination Long-haul Trucks" = 62,
#   )
#   )  %>%
#   select(scc, sourcetype) %>%
#   distinct()
# 
# scc %>% View()
# scc %>% 
#   filter(scc == 2203530100)

read_rds("dev/VPOP.rds") %>% 
  # left_join(by = "scc", y = scc) %>%
  # filter(is.na(sourcetype)) %>%
  # Some sccs are not in our crosswalk, but we can extract out our sourcetypeids
  mutate(sourcetype = str_sub(scc, 5,6) %>% as.integer()) %>%
  group_by(geoid, sourcetype, year) %>%
  summarize(vehicles = sum(vehicles, na.rm = TRUE), .groups = "drop") %>%
  saveRDS("dev/nei_sourcetypeyear.rds")

# read_rds("dev/nei_sourcetypeyear.rds") %>%
#   filter(is.na(sourcetype))


# stat = read_rds("dev/nei_sourcetypeyearvmt.rds") %>%
#   group_by(year, sourcetype) %>%
#   summarize(mean = mean(vmt, na.rm = TRUE),
#             se = sd(vmt, na.rm = TRUE) / sqrt(n())) %>%
#   ungroup()
# library(ggplot2)
# ggplot() +
#   geom_point(data = stat, mapping = aes(x = sourcetype, y = mean, color = as.factor(year) ))
# 

# STAT ############################################

# read_rds("dev/nei_sourcetypeyear.rds") %>%
#   group_by(geoid, sourcetype) %>%
#   reframe(vehicles =  lm(formula = vehicles ~ year) %>% 
#             predict(object = ., newdata = tibble(year = year)))


# .year = 2018
# .geoidchar = "36109"
# 
# read_rds("dev/nei_sourcetypeyear.rds") %>%
#   filter(geoid == .geoidchar) %>%
#   group_by(sourcetype) %>%
#   reframe(
#     vehicles = lm(formula = vehicles ~ year) %>%
#       predict(object = ., newdata = tibble(year = .year)),
#     year = .year)
# 
# 
# read_rds("dev/nei_sourcetypeyearvmt.rds")  %>%
#   group_by(year) %>%
#   summarize(VMT = sum(vmt, na.rm = TRUE))
# 
# read_csv("defaults/hpmsvtypeyear.csv") %>%
#   group_by(yearID) %>%
#   summarize(VMT = sum(HPMSBaseYearVMT, na.rm = TRUE))



# see scripts/adapt_from_nei.Rs








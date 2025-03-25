R
library(dplyr)
library(DBI)
library(readr)
library(dbplyr)
library(catr)

setwd("/cat")
source("scripts/adapt_functions.R")

dir()
rs = catr::translate_rs(.runspec = "EPA_MOVES_Model/rs_custom.xml")
rs
.custom = rs$defaultdbname
.geoid =rs$geoid
.geoidchar = stringr::str_pad(rs$geoid, width = 5, side = "left", pad = "0")
.year = rs$year


fuelsupply = read_csv("scripts/defaults/fuelsupply.csv")

fuelsupply %>%  filter(fuelFormulationID == 20)




db = connect("mariadb", .custom)
    
  
    q1 = db %>% 
      tbl("regioncounty") %>%
      filter(countyID == !!.geoid, fuelYearID %in% !!.year) %>%
      select(regionID, fuelYearID) %>%
      distinct()
    
    # Now get the fuelsupply table for that fuelregion and year
    q2 = db %>% 
      tbl("fuelsupply") %>%
      inner_join(by = c("fuelYearID", "fuelRegionID" = "regionID"), y = q1) %>%
      # and return the distinct fuel formulations for it
      select(fuelFormulationID) %>%
      distinct()

    data = db %>% tbl("fuelformulation") %>% 
      # Narrow into just the fuel formulations described by the fuelsupply table
      inner_join(by = c("fuelFormulationID"),
                 y = q2) %>%
      arrange(fuelFormulationID, fuelSubtypeID) %>%
      collect()
    
    # Check and see if the main fuelsubtypes are accounted for.
    if(any(!data$fuelSubtypeID %in% c(10,20,30,51,90)) ){
      # If any are not, import this file
        extra = read_csv("scripts/helper_fuelformulation.csv", show_col_types = FALSE)
        
        # For each of these main fuel subtypes,
        for(i in c(10,20,30,51,90)){
          # If they are missing, ADD THEM from our default NY data.
          if(!any(data$fuelSubtypeID %in% i)){
              data = data %>% filter(fuelSubtypeID != i) %>% 
                bind_rows(extra %>% filter(fuelSubtypeID == i), .)
          }
          
      }

    }
    
    # Fill in any missing data with 0
    data = data %>% 
      mutate(across(.cols = RVP:T90, .f = ~if_else(is.na(.x), true = 0, false = .x)))


bind_rows(extra, data)
pdata = read_csv("scripts/defaults/fuelformulation.csv")

fuelformulation




db = connect("mariadb", "movesdb20241112")
db %>% tbl("fuelsubtype")

fuelsupply
fuelsupply %>% filter(fuelFormulationID == 20)

# Connect to database
custom = connect("mariadb", .custom)

q1 = custom %>% 
  tbl("regioncounty") %>%
  filter(countyID == !!.geoid, fuelYearID %in% !!.year) %>%
  select(regionID, fuelYearID) %>%
  distinct()

custom %>% 
  tbl("fuelsupply") %>%
  inner_join(by = c("fuelYearID", "fuelRegionID" = "regionID"), y = q1) %>%
  arrange(fuelRegionID, fuelYearID, monthGroupID, fuelFormulationID) 




fakedata = custom %>% 
  tbl("sourcetypeagedistribution") %>%
  filter(yearID == 2022) %>%
  collect()

fakedata %>% 
  group_by(sourceTypeID) %>%
  count()



# By default it is NOT empty
fakedata = custom %>%
  tbl("samplevehiclepopulation") %>%
  group_by(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
  summarize(fuelEngFraction = sum(stmyFraction, na.rm = TRUE), .groups = "drop") %>%
  ungroup()  %>%
  collect()

data = get_data(changes = "inputs/avft.csv", .geoidchar ) %>%
      select(sourceTypeID = sourcetypeid,
             modelYearID = modelyearid,
             fuelTypeID = fueltypeid,
             engTechID = engtechid,
             fuelEngFraction = fuelengfraction)
    
fakedata %>% 
  group_by(sourceTypeID) %>%
  count()

data %>%
  group_by(sourcetypeid) %>%
  count()

# Find all the strata that are MISSING in the observed data,
# but are available in the default data.
# Set them all to zero, and bind them in.
extrarows = fakedata %>%
  select(sourceTypeID, modelYearID, fuelTypeID, engTechID) %>%
  distinct() %>%
  anti_join(
    by = c("sourceTypeID", "modelYearID", "fuelTypeID", "engTechID"),
    y = data) %>%
  mutate(fuelEngFraction = 0)

bind_rows(data, extrarows)
nrow(fakedata)

bind_rows(data, extrarows) %>%
  group_by(sourceTypeID) %>%
  count()
  
  
  
q()
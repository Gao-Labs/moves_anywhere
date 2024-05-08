#' @name workflow.R
#' @author Tim Fraser
#' @description
#' Workflow that demos the creation of custom runspec.xml documents

library(dplyr)
library(catr)
library(xml2)

#pollutantprocessassoc
# https://github.com/USEPA/EPA_MOVES_Model/blob/master/docs/AnatomyOfARunspec.md#pollutant-process-associations

rs = catr::rs_template_rate

rs$runspec$pollutantprocessassociations %>% str()
rs$runspec$pollutantprocessassociations[[4]]

# Every pollutant needs the following information:
# pollutantkey
# pollutantname
# processkey
# processname


c(90, 98, 2, 118, 112, 119, 5, 6, 79, 3, 100, 110, 106, 107, 116, 117, 115, 31, 91, 1, 87)

# For example, pollutant 98 involves 4 processes - process 1, 2, 90, and 91.
catr::tab_pollutantprocessassoc %>%
  filter(pollutantID == 98) %>%
  with(processID)

catr::tab_pollutantprocessassoc  %>%
  filter(processID %in% c(1,2,90, 91)) %>%
  with(pollutantID) %>%
  unique()



set_attributes = function(.pollutantID, .pollutantName, .processID, .processName){
  output = list()
  attr(output, "pollutantkey") <- as.character(.pollutantID)
  attr(output, "pollutantname") <- as.character(.pollutantName)
  attr(output, "processkey") <- as.character(.processID)
  attr(output, "processname") <- as.character(.processName)
  return(output)
}

get_attributes = function(.list){
  tibble(
    pollutantID = attr(.list, "pollutantkey"),
    pollutantName = attr(.list, "pollutantname"),
    processID = attr(.list, "processkey"),
    processName = attr(.list, "processname")
  )
}


# validprocesses = tab_emissionprocess %>% 
#   # Get the list of valid processes for onroad emissions
#   filter(processID %in% c(
#     # Running/Start Exhaust
#     1, 2, 
#     # Crankcase
#     15, 16, 17, 
#     # Extendend Idle
#     90,
#     # Other Hotelling Exhaust = Auxilary Power Exhaust
#     91, 
#     # Evap
#     11, 12, 13,
#     # Refueling
#     18, 19,
#     # Brakewear, Tirewear
#     9, 10
#   ))

validprocesses = c(
  # Running/Start Exhaust
  1, 2, 
  # Crankcase
  15, 16, 17, 
  # Extendend Idle
  90,
  # Other Hotelling Exhaust = Auxilary Power Exhaust
  91, 
  # Evap
  11, 12, 13,
  # Refueling
  18, 19,
  # Brakewear, Tirewear
  9, 10
)



#c(1, 2, 15, 16, 17, 90, 91, 11, 12, 13, 18, 19)

# Let's make the current version of `custom_rs()` 
# just be able to select any pollutant overall.

# This means, if you want certain specific pollutant processes,
# you'll need to write the runspec yourself.
# But if you just want to click on pollutants overall and get their prerequisites,
# this code will do that.
.pollutants = c(1,2)
.p = 1

# If the supplied pollutant IDs, give me all required polProcessIDs

get_polProcessID = function(.pollutantID, .processID){
  # Testing Values
  # .pollutantID = 79; .processID = c(1, 2, 15)
  # Update the processID
  .processID = stringr::str_pad(.processID, width = 2, side = "left", pad = 0)
  # Concatenate the .pollutantID onto it
  .polprocessID = paste0(.pollutantID, .processID)
  return(.polprocessID)
}

# All items except brakewear and tirewear 
items_no_brt = c(1, 2, 15, 16, 17, 90, 91, 11, 12, 13, 18, 19)
# All items except evap, refueling, and brakewear or tirewear
items_no_evap_ref_brt = c(1,2,15,16,17,90,91)
# All items including exhaust - but not crankcase
items_exhaust = c(1,2,90,91)
# Just a small subset
items_mini = c(1,2,15,16)

switch(
  EXPR = as.character(.p),
  # Total Gaseous Hydrocarbons
  "1" = get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
  # Non-Methane Hydrocarbons
  "79" = c(
    get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 79, .processID = items_no_brt)
  ),
  # Non-Methane Organic Gases
  "80" = c(
    get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 80, .processID = items_no_brt)
  ),
  # Total Organic Gases
  "86" = c(
    get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 80, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 86, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 5, .processID = items_no_evap_ref_brt)
  ),
  # Volatile Organic Compounds (VOC)
  "87" = c(
    get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
    get_polProcessID(.pollutantID = 87, .processID = items_no_brt)
  ),
  # Methane
  "5" = c(
    get_polProcessID(.pollutantID = 1, .processID = items_no_evap_ref_brt),
    get_polProcessID(.pollutantID = 5, .processID = items_no_evap_ref_brt)
  ),
  # Carbon Monoxide
  "2" = c(
    get_polProcessID(.pollutantID = 2, .processID = items_no_evap_ref_brt)
  ),
  # Oxides of Nitrogen (NOx)
  "3" = c(
    get_polProcessID(.pollutantID = 3, .processID = items_no_evap_ref_brt)
  ),
  # Nitrogen Oxide (NO)
  "32" = c(
    get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
    get_polProcessID(.pollutantID = 32, .processID = items_no_evap_ref_brt)
  ),
  # Nitrogen Dioxide (NO2)
  "33" = c(
    get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
    get_polProcessID(.pollutantID = 33, .processID = items_no_evap_ref_brt)
  ),
  # Nitrous Acid (HONO)
  "34" = c(
    get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
    get_polProcessID(.pollutantID = 34, .processID = items_no_evap_ref_brt)
  ),
  # Ammonia (NH3)
  "36" = c(
    get_polProcessID(.pollutantID = 36, .processID = items_no_evap_ref_brt)
  ),
  # Nitrous Oxide (N20)
  "6" = c(
    get_polProcessID(.pollutantID = 6, .processID = items_mini)
  ),
  # Primary Exhaust PM2.5 - Total
  "100" = c(
    get_polProcessID(.pollutantID = 100, .processID = items_no_evap_ref_brt),
    get_polProcessID(.pollutantID = 118, .processID = items_mini),
    get_polProcessID(.pollutantID = 112, .processID = items_mini),
    get_polProcessID(.pollutantID = 119, .processID = items_mini),
    get_polProcessID(.pollutantID = 115, .processID = items_mini)
  )
  # Primary Exhaust ...
)


# chains = catr::tab_pollutantprocessassoc %>%
#   # Filter to just valid processes that show up for the onroad menu
#   filter(processID %in% validprocesses) %>%
#   # Filter to your pollutant
#   #filter(pollutantID == 79) %>%
#   # Get back list of pollutant processes that occur for onroad menu, 
#   # plus any other chained onroad or nonroad processes 
#   select(pollutantID, polProcessID, contains("chain")) %>%
#   # For each pollutant and pollutant process,
#   group_by(pollutantID, polProcessID) %>%
#   # Give me the unique list of all pollutant process IDs that are chained to it,
#   # INCLUDING the original pollutant process.
#   reframe(
#     req = c(polProcessID, chainedto1, chainedto2, 
#             nrChainedTo1, nrChainedTo2) %>% unique() %>% .[!is.na(.)]
#   )


# We can use chains to filter.
# So, if we filter chains by pollutant,
# the resulting `req` should be ALL polProcessIDs required.

#.pollutants = c(98)
# 
# 
# pdata = chains %>%
#   filter(pollutantID %in% .pollutants) %>%
#   select(req) %>%
#   mutate(processID = req %>% stringr::str_sub(-2, -1) %>% as.integer(),
#          pollutantID = req %>% stringr::str_sub(0, -3) %>% as.integer()) %>%
#   # And join in the pollutant name and process names
#   left_join(by = "processID", 
#             y = catr::tab_emissionprocess %>% select(processID, processName)) %>%
#   left_join(by = "pollutantID",
#             y = catr::tab_pollutant %>% select(pollutantID, pollutantName)) %>%
#   # For each row...
#   mutate(row = 1:n()) %>%
#   arrange(pollutantID, processID)

plist = pdata %>% 
  # Split into a list
  split(.$row) %>% 
  # For each item, set attributes
  purrr::map(~set_attributes(.pollutantID = .$pollutantID, .pollutantName = .$pollutantID, 
                             .processID = .$processID, .processName = .$processName)) %>% 
  # Set the name of each to be pollutant process association.
  setNames(., nm = rep("pollutantprocessassociation", length(.)) )

plist
# 
# catr::tab_pollutantprocessassoc %>%
#   select(polProcessID, chainedto1, chainedto2) %>%
#   tidyr::pivot_longer(cols = c(contains("chainedto")),
#                       names_to = "name", 
#                       values_to = "chainedto",
#                       values_drop_na = TRUE)

# rs$runspec$pollutantprocessassociations %>% 
#   purrr::map_dfr(~get_attributes(.))
# 
# catr::tab_emissionprocess %>% 
#   #select(processID, processName) %>%
#   filter( isAffectedByOnroad == 1) %>%
#   View()
#   filter(stringr::str_detect(processName, "Nonroad"))

#' @note Functions for getting pollutant information

# testing:
# library(stringr)

#' @name get_polProcessID
#' @title Get Pollutant-Process ID
#' @author Tim Fraser
#' @description
#' Concatenate pollutant and process ID information
#' Given a supplied pollutant ID and .processID, give me all required polProcessIDs
#' @importFrom stringr str_pad
get_polProcessID = function(.pollutantID, .processID){
  # Testing Values
  # .pollutantID = 79; .processID = c(1, 2, 15)
  # Update the processID
  .processID = str_pad(.processID, width = 2, side = "left", pad = 0)
  # Concatenate the .pollutantID onto it
  .polprocessID = paste0(.pollutantID, .processID)
  return(.polprocessID)
}

#' @name get_simple
#' @title Get Simple Cases of Required Pollutant-Process IDs 
#' @author Tim Fraser
#' @description
#' Many Metals, Dioxins, and Furans are just running exhaust (XX1)
#' plus Total Gaseous Hydrocarbons (101)
#' This function will get the polProcessIDs for such cases more quickly.
get_simple = function(.pollutantID = 67){
  c(get_polProcessID(.pollutantID = .pollutantID, .processID = 1),
    get_polProcessID(.pollutantID = 1, .processID = 1))  
}

#' @name get_particle
#' @title Get Particle-relevant cases of Required Pollutant-Process IDs.
#' @author Tim Fraser
#' @description
#' Several species of primary exhaust PM2.5 all share the same prerequisites
#' This function will get the polProcessIDs for such cases more quickly.
get_particle = function(.pollutantID = 58){
  c(get_polProcessID(.pollutantID = .pollutantID, .processID = c(1,2,15,16,17,90,91)),
    get_polProcessID(.pollutantID = 118, .processID = c(1,2,90,91)),
    get_polProcessID(.pollutantID = 119, .processID = c(1,2,90,91)),
    get_polProcessID(.pollutantID = 115, .processID = c(1,2,90,91))
  ) %>%
    unique()
}


#' @name get_polprocesses
#' @title Get Required Pollutant-Process ID sets given an inputted `.pollutantID`.
#' @author Tim Fraser
#' 
#' @param .pollutantID (integer) pollutant ID
#'
#' @description
#' For any `.pollutantID` supplied, this function will return a character `vector` of 
#' all Pollutant-Process IDs required to measure that pollutant's emissions.
#' This corresponds to clicking on a Pollutant
#' in the "Selected" column of the MOVES GUI, 
#' then clicking "Select Prerequisites".
#' 
#' NOTE: This does NOT allow you to select a specific pollutant-process 
#' THEN get all required derivative pollutant-processes.
#' This only works with an overall pollutant as an input, where it assumes 
#' you want to estimate that pollutant for ALL its relevant pollutant processes. 
#' @export
get_polprocesses = function(.pollutantID = 98){
  
  # All items except brakewear and tirewear 
  items_no_brt = c(1, 2, 15, 16, 17, 90, 91, 11, 12, 13, 18, 19)
  # All items except crankcase, brakewear, and tirewear
  items_no_crank_brt = c(1, 2, 90, 91, 11, 12, 13, 18, 19)
  # All items except evap, refueling, and brakewear or tirewear
  items_no_evap_ref_brt = c(1,2,15,16,17,90,91)
  # All items including exhaust - but not crankcase
  items_exhaust = c(1,2,90,91)
  # Just a small subset
  items_mini = c(1,2,15,16)
  
  output = switch(
    EXPR = as.character(.pollutantID),
    # Total Gaseous Hydrocarbons ###############################
    "1" = get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
    # Non-Methane Hydrocarbons ###############################
    "79" = c(
      get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_brt)
    ),
    # Non-Methane Organic Gases ###############################
    "80" = c(
      get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 80, .processID = items_no_brt)
    ),
    # Total Organic Gases ###############################
    "86" = c(
      get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 80, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 86, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 5, .processID = items_no_evap_ref_brt)
    ),
    # Volatile Organic Compounds (VOC) ###############################
    "87" = c(
      get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_brt)
    ),
    # Methane ###############################
    "5" = c(
      get_polProcessID(.pollutantID = 1, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 5, .processID = items_no_evap_ref_brt)
    ),
    # Carbon Monoxide ###############################
    "2" = c(
      get_polProcessID(.pollutantID = 2, .processID = items_no_evap_ref_brt)
    ),
    # Oxides of Nitrogen (NOx) ###############################
    "3" = c(
      get_polProcessID(.pollutantID = 3, .processID = items_no_evap_ref_brt)
    ),
    # Nitrogen Oxide (NO) ###############################
    "32" = c(
      get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 32, .processID = items_no_evap_ref_brt)
    ),
    # Nitrogen Dioxide (NO2) ###############################
    "33" = c(
      get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 33, .processID = items_no_evap_ref_brt)
    ),
    # Nitrous Acid (HONO) ###############################
    "34" = c(
      get_polProcessID(.pollutantID = 3, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 34, .processID = items_no_evap_ref_brt)
    ),
    # Ammonia (NH3) ###############################
    "30" = c(
      get_polProcessID(.pollutantID = 30, .processID = items_no_evap_ref_brt)
    ),
    # Nitrous Oxide (N20) ###############################
    "6" = c(
      get_polProcessID(.pollutantID = 6, .processID = items_mini)
    ),
    # Primary Exhaust PM2.5 - Total ###############################
    "110" = c(
      get_polProcessID(.pollutantID = 110, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 112, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    # Primary PM2.5 - Brakewear Particulate ###############################
    "116" = c(
      get_polProcessID(.pollutantID = 116, .processID = 9),
      get_polProcessID(.pollutantID = 115, .processID = 1),
      get_polProcessID(.pollutantID = 118, .processID = 1),
      get_polProcessID(.pollutantID = 112, .processID = 1),
      get_polProcessID(.pollutantID = 119, .processID = 1),
      get_polProcessID(.pollutantID = 110, .processID = 1)
    ),
    # Primary PM2.5 - Tirewear Particulate ###############################
    "117" = c(
      get_polProcessID(.pollutantID = 117, .processID = 10),
      get_polProcessID(.pollutantID = 115, .processID = 1),
      get_polProcessID(.pollutantID = 118, .processID = 1),
      get_polProcessID(.pollutantID = 112, .processID = 1),
      get_polProcessID(.pollutantID = 119, .processID = 1),
      get_polProcessID(.pollutantID = 110, .processID = 1)
    ),
    # Primary Exhaust PM10 - Total ###############################
    "100" = c(
      get_polProcessID(.pollutantID = 100, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 110, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 112, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    #Primary PM10 - Brakewear ###############################
    "106" = c(
      get_polProcessID(.pollutantID = 106, .processID = 9),
      get_polProcessID(.pollutantID = 116, .processID = 9),
      
      get_polProcessID(.pollutantID = 110, .processID = 1),
      get_polProcessID(.pollutantID = 115, .processID = 1),
      get_polProcessID(.pollutantID = 118, .processID = 1),
      get_polProcessID(.pollutantID = 112, .processID = 1),
      get_polProcessID(.pollutantID = 119, .processID = 1)
    ),
    # Primary PM10 - Tirewear ###############################
    "107" = c(
      get_polProcessID(.pollutantID = 107, .processID = 10),
      get_polProcessID(.pollutantID = 117, .processID = 10),
      
      get_polProcessID(.pollutantID = 110, .processID = 1),
      get_polProcessID(.pollutantID = 115, .processID = 1),
      get_polProcessID(.pollutantID = 118, .processID = 1),
      get_polProcessID(.pollutantID = 112, .processID = 1),
      get_polProcessID(.pollutantID = 119, .processID = 1)
    ),
    
    # Sulfur Dioxide (SO2) ###############################
    "31" = c(
      get_polProcessID(.pollutantID = 31, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 91, .processID = items_exhaust)
    ),
    # Total Energy Consumption ###############################
    "91" = c(
      get_polProcessID(.pollutantID = 91, .processID = items_exhaust)
    ),
    # Atmospheric CO2 ###############################
    "90" = c(
      get_polProcessID(.pollutantID = 90, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 91, .processID = items_exhaust)
    ),
    # CO2 Equivalent (!!!)  ###############################
    "98" = c(
      get_polProcessID(.pollutantID = 98, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 90, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 91, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 6, .processID = c(1,2)),
      get_polProcessID(.pollutantID = 5, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    # Benzene ###############################
    "20" = c(
      get_polProcessID(.pollutantID = 20, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    # Ethanol ###############################
    "21" = c(
      get_polProcessID(.pollutantID = 21, .processID = c(1, 2, 15, 16,  11, 12, 13, 18, 19)),
      get_polProcessID(.pollutantID = 87, .processID = c(1, 2, 11, 12, 13, 18, 19)),
      get_polProcessID(.pollutantID = 79, .processID = c(1, 2, 11, 12, 13, 18, 19)),
      get_polProcessID(.pollutantID = 1, .processID = c(1, 2, 11, 12, 13, 18, 19))
    ),
    # 1,3-Butadiene ###############################
    "24" = c(
      get_polProcessID(.pollutantID = 24, .processID = c(1, 2, 15, 16,17, 90, 91)),
      get_polProcessID(.pollutantID = 87, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 79, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 1, .processID = c(1, 2, 90, 91))
    ),
    # Formaldehyde ###############################
    "25" = c(
      get_polProcessID(.pollutantID = 25, .processID = c(1, 2, 15, 16,17, 90, 91)),
      get_polProcessID(.pollutantID = 87, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 79, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 1, .processID = c(1, 2, 90, 91))
    ),
    # Acetaldehyde ###############################
    "26" = c(
      get_polProcessID(.pollutantID = 26, .processID = c(1, 2, 15, 16,17, 90, 91)),
      get_polProcessID(.pollutantID = 87, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 79, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 1, .processID = c(1, 2, 90, 91))
    ),
    # Acrolein ###############################
    "27" = c(
      get_polProcessID(.pollutantID = 27, .processID = c(1, 2, 15, 16,17, 90, 91)),
      get_polProcessID(.pollutantID = 87, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 79, .processID = c(1, 2, 90, 91)),
      get_polProcessID(.pollutantID = 1, .processID = c(1, 2, 90, 91))
    ),
    # Non-HAPTOG Mechanism ###############################
    "88" = c(
      get_polProcessID(.pollutantID = 88, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 80, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 20, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 21, .processID = c(1, 2, 15, 16,  11, 12, 13, 18, 19)),
      get_polProcessID(.pollutantID = 24, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 25, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 26, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 27, .processID = items_no_evap_ref_brt),
      ## Additional Air toxics
      get_polProcessID(.pollutantID = 40, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 41, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 42, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 43, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 44, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 45, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 46, .processID = items_no_brt),
      ## PAHs
      get_polProcessID(.pollutantID = 185, .processID = items_no_brt)
    ),
    # Additional Air Toxics Submenu #################
    ## 2,2,4-Trimethylpentane ##################
    "40" = c(
      get_polProcessID(.pollutantID = 40, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    ## Ethyl-Benzene #####################
    "41" = c(
      get_polProcessID(.pollutantID = 41, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    ## Hexane ############################
    "42" = c(
      get_polProcessID(.pollutantID = 42, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    ## Propionaldehyde ############################
    "43" = c(
      get_polProcessID(.pollutantID = 43, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Styrene ############################
    "44" = c(
      get_polProcessID(.pollutantID = 44, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Toluene ############################
    "45" = c(
      get_polProcessID(.pollutantID = 45, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    ## Xylene ############################
    "46" = c(
      get_polProcessID(.pollutantID = 46, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)
    ),
    # Polycyclic Aromatic Hydrocarbons (PAH) submenu ############
    ## Acenapthene gas ############################
    "170" = c(
      get_polProcessID(.pollutantID = 170, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Acenapthene particle ############################
    "70" = c(
      get_polProcessID(.pollutantID = 70, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Anapthylene Gas ############################
    "171" = c(
      get_polProcessID(.pollutantID = 171, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Anapthylene Particles ############################
    "71" = c(
      get_polProcessID(.pollutantID = 71, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Anthracene Gas ############################
    "172" = c(
      get_polProcessID(.pollutantID = 172, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Anthracene Particle ############################
    "72" = c(
      get_polProcessID(.pollutantID = 72, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Benz(a)anthracene gas ############################
    "173" = c(
      get_polProcessID(.pollutantID = 173, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Benz(a)anthracene particle ############################
    "73" = c(
      get_polProcessID(.pollutantID = 73, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Benzo(a)pyrene gas ############################
    "174" = c(
      get_polProcessID(.pollutantID = 174, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Benzo(a)pyrene particle ############################
    "74"  = c(
      get_polProcessID(.pollutantID = 74, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Benzo(b)fluoranthene gas ############################
    "175" = c(
      get_polProcessID(.pollutantID = 175, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Benzo(b)fluoranthene particle ############################
    "75" = c(
      get_polProcessID(.pollutantID = 75, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Benzo(g,h,i)perylene gas ############################
    "176" = c(
      get_polProcessID(.pollutantID = 176, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Benzo(g,h,i)perylene particle ############################
    "76" = c(
      get_polProcessID(.pollutantID = 76, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Benzo(k)fluoranthene gas ############################
    "177" = c(
      get_polProcessID(.pollutantID = 177, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Benzo(k)fluoranthene particle ############################
    "77" = c(
      get_polProcessID(.pollutantID = 77, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Chrysene gas ############################
    "178" = c(
      get_polProcessID(.pollutantID = 178, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Chrysene particle ############################
    "78" = c(
      get_polProcessID(.pollutantID = 78, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Dibenzo(a,h)anthracene gas ############################
    "168" = c(
      get_polProcessID(.pollutantID = 168, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    # Dibenzo(a,h)anthracene particle
    "68" = c(
      get_polProcessID(.pollutantID = 68, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Fluoranthene gas ############################
    "169" = c(
      get_polProcessID(.pollutantID = 169, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Fluoranthene particle ############################
    "69" = c(
      get_polProcessID(.pollutantID = 69, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Fluorene Gas  ############################
    # 181 (this is not a typo - it is 181 vs. 80)
    "181" = c(
      get_polProcessID(.pollutantID = 181, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Fluorene Particle  ############################
    # (this is not a typo - it is 80 vs. 181)
    "80" = c(
      get_polProcessID(.pollutantID = 80, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Indeno(1,2,3,c,d)pyrene gas ############################
    "182" = c(
      get_polProcessID(.pollutantID = 182, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Indeno(1,2,3,c,d)pyrene particle ############################
    "81" = c(
      get_polProcessID(.pollutantID = 81, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Naphthalene gas ############################
    "185" = c(
      get_polProcessID(.pollutantID = 185, .processID = items_no_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 79, .processID = items_no_crank_brt),
      get_polProcessID(.pollutantID = 1, .processID = items_no_crank_brt)    
    ),
    ## Naphthalene particle ############################
    "23" = c(
      get_polProcessID(.pollutantID = 23, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Phenanthrene gas ############################
    "183" = c(
      get_polProcessID(.pollutantID = 183, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Phenanthrene particle ############################
    "82" = c(
      get_polProcessID(.pollutantID = 82, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    ## Pyrene Gas ############################
    "184" = c(
      get_polProcessID(.pollutantID = 184, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 87, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 79, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 1, .processID = items_exhaust)
    ),
    ## Pyrene Particle ############################
    "84" = c(
      get_polProcessID(.pollutantID = 84, .processID = items_no_evap_ref_brt),
      get_polProcessID(.pollutantID = 118, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 119, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 111, .processID = items_exhaust),
      get_polProcessID(.pollutantID = 115, .processID = items_exhaust)
    ),
    # Metals submenu ###########################
    ## Arsenic Compounds ##########################
    "63" = get_simple(63),
    ## Chromium 6+ #########################
    "65" = get_simple(65),
    ## Mercury Divalent Gaseous ########################
    "61" = get_simple(61),
    ## Mercury Elemental Gaseous ########################
    "60" = get_simple(60),
    ## Mercury Particulate ########################
    "62" =  get_simple(62),
    ## Nickel Compounds ###############################
    "67" =  get_simple(67),
    # Dioxins and Furans Submenu #############################
    # [1-hepta] 1,2,3,4,6,7,8-Heptachlorodibenzo-p-Dioxin
    "132" = get_simple(.pollutantID = 132),
    # [2-hepta] 1,2,3,4,6,7,8-Heptachlorodibenzofuran
    "144" = get_simple(.pollutantID = 144),
    # [3-hepta] 1,2,3,4,7,8,9-Heptachlorodibenzofuran
    "137" = get_simple(.pollutantID = 137),
    
    # [1-hexa] 1,2,3,4,7,8-Hexachlorodibenzo-p-Dioxin
    "134" = get_simple(.pollutantID = 134),
    # [2-hexa] 1,2,3,4,7,8-Hexachlorodibenzofuran
    "145" = get_simple(.pollutantID = 145),
    # [3-hexa] 1,2,3,6,7,8-Hexachlorodibenzo-p-Dioxin
    "141" = get_simple(.pollutantID = 141),
    # [4-hexa] 1,2,3,6,7,8-Hexachlorodibenzofuran
    "140" = get_simple(.pollutantID = 140),
    # [5-hexa] 1,2,3,7,8,9-Hexachlorodibenzo-p-Dioxin
    "130" = get_simple(.pollutantID = 130),
    # [6-hexa] 1,2,3,7,8,9-Hexachlorodibenzofuran
    "146" = get_simple(.pollutantID = 146),
    
    # [1-penta] 1,2,3,7,8-Pentachlorodibenzo-p-Dioxin
    "135" = get_simple(.pollutantID = 135),
    # [2-penta] 1,2,3,7,8-Pentachlorodibenzofuran
    "139" = get_simple(.pollutantID = 139),
    
    # "2,3,4,6,7,8-Hexachlorodibenzofuran"
    "143" = get_simple(.pollutantID = 143),
    # 2,3,4,7,8-Pentachlorodibenzofuran
    "138" = get_simple(.pollutantID = 138),
    
    # 2,3,7,8-Tetrachlorodibenzo-p-Dioxin
    "142" = get_simple(.pollutantID = 142),
    # 2,3,7,8-Tetrachlorodibenzofuran
    "136" = get_simple(.pollutantID = 136),
    
    # Octachlorodibenzo-p-dioxin
    "131" = get_simple(.pollutantID = 131),
    # Octachlorodibenzofuran
    "133" = get_simple(.pollutantID = 133),
    
    # Primary Exhaust PM2.5 - Species #################################
    ## Aluminum
    "58"= get_particle(58),
    ## Ammonium (NH4)
    "36" = get_particle(36),
    ## Calcium
    "55" = get_particle(55),
    ## Chloride
    "51" = get_particle(51),
    ## CMAQ5.0 Unspeciated (PMOTHR)
    "121" = get_particle(121),
    ## Composite - NonECPM
    "118" = get_particle(118),
    ## Elemental Carbon
    "112" = get_polProcessID(.pollutantID = 112, .processID = c(1,2,15,16,17,90,91)),
    ## H20 (aerosol)
    "119" = get_particle(119),
    ## Iron
    '59' = get_particle(59),
    ## Magnesium
    '54' = get_particle(54),
    ## Manganese Compounds
    "66" = get_simple(66),
    ## Nitrate (NO3)
    "35" = get_particle(35),
    ## Non-carbon Organic Matter (NCOM)
    "122" = get_particle(122),
    # Organic Carbon
    "111" = get_particle(111),
    # Potassium
    "53" = get_particle(53),
    # Residual PM (NonECNonSO4NonOM)
    "124" = c(
      get_polProcessID(.pollutantID = 124, .processID = c(1,2,15,16,17,90,91)),
      
      get_polProcessID(.pollutantID = 118, .processID = c(1,2,90,91)),
      get_polProcessID(.pollutantID = 119, .processID = c(1,2,90,91)),
      get_polProcessID(.pollutantID = 115, .processID = c(1,2,90,91)),
      
      get_polProcessID(.pollutantID = 122, .processID = c(1,2,15,16,17,90,91)),
      get_polProcessID(.pollutantID = 111, .processID = c(1,2,15,16,17,90,91)),
      get_polProcessID(.pollutantID = 123, .processID = c(1,2,15,16,17,90,91))
    ),
    # Silicon
    "57" = get_particle(57),
    # Sodium
    "52" = get_particle(52),
    # Sulfate Particulate
    "115" = get_particle(115),
    # Titanium
    "56" = get_particle(56),
    # Total Organic Matter
    "123" = c(
      get_polProcessID(.pollutantID = 123, .processID = c(1,2,15,16,17,90,91)),
      
      get_polProcessID(.pollutantID = 118, .processID = c(1,2,90,91)),
      get_polProcessID(.pollutantID = 119, .processID = c(1,2,90,91)),
      get_polProcessID(.pollutantID = 115, .processID = c(1,2,90,91)),
      
      get_polProcessID(.pollutantID = 122, .processID = c(1,2,15,16,17,90,91)),
      get_polProcessID(.pollutantID = 111, .processID = c(1,2,15,16,17,90,91))
    )
  )
  # If output is null, make it be empty
  if(is.null(output)){ output = c() }
  return(output)
}

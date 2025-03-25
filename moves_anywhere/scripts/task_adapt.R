# task_adapt.R

# Script to get a vector of csvs

# Testing values
# FOLDER=paste0(rstudioapi::getActiveProject(), "/moves_anywhere")
# BUCKET=paste0(rstudioapi::getActiveProject(), "/moves_anywhere/inputs_ny")
# R

# Message start
cat("\n\n---ADAPTING INPUT TABLES------------------\n")

# Runtime Variables
FOLDER="/cat/"
BUCKET="inputs"
.runspec = "EPA_MOVES_Model/rs_custom.xml"
.volume=BUCKET

# Set working directory to /cat/
setwd(FOLDER)

# Load packages
library(catr, warn.conflicts = FALSE,  quietly = TRUE)
library(DBI, warn.conflicts = FALSE, quietly = TRUE)
library(RMariaDB, warn.conflicts = FALSE,  quietly = TRUE)
library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
# Load functions
source("scripts/adapt_functions.R")

# IDENTIFIERS ####################################
cat("\n\n---IDENTIFER TABLES----------------------\n")
source("scripts/adapt_ids.R")
adapt_ids(.runspec = .runspec)

## FUEL ###############################################
cat("\n\n---FUELS----------------------------------\n")
source("scripts/adapt_fuel.R")
adapt_fuelformulation(.runspec = .runspec)
adapt_fuelsupply(.runspec = .runspec)
adapt_fuelusagefraction(.runspec = .runspec)
adapt_avft(.runspec = .runspec)


# SOURCETYPE YEAR #################################
cat("\n\n---VEHICLE POPULATION TABLES----------------------\n")
source("scripts/adapt_sourcetypeyear.R")
adapt_sourcetypeyear(.runspec = .runspec)

# VMT #################################
cat("\n\n---VEHICLE VMT TABLES----------------------\n")
source("scripts/adapt_vmt.R")
adapt_vmt(.runspec = .runspec)

# VMT FRACTIONS ########################################
cat("\n\n---VMT FRACTION TABLES----------------------\n")
source("scripts/adapt_vmtfraction.R")
adapt_dayvmtfraction(.runspec = .runspec)
adapt_hourvmtfraction(.runspec = .runspec)
adapt_monthvmtfraction(.runspec = .runspec)

## AGE DISTRIBUTION ####################################
cat("\n\n---AGE DISTRIBUTION TABLES----------------------\n")
source("scripts/adapt_sourcetypeagedistribution.R")  
adapt_sourcetypeagedistribution(.runspec = .runspec)


## SPEED DISTRIBUTION ##################################
cat("\n\n---AVG SPEED DISTRIBUTION TABLES----------------------\n")
source("scripts/adapt_avgspeeddistribution.R")
adapt_avgspeeddistribution(.runspec = .runspec)


## ROADTYPE VMT ########################################
cat("\n\n---ROADTYPE DISTRIBUTION TABLES-----------------------\n")
source("scripts/adapt_roadtypedistribution.R")
adapt_roadtypedistribution(.runspec = .runspec)


## STARTS ##############################################
cat("\n\n---STARTS TABLES-----------------------------\n")
source("scripts/adapt_starts.R")
adapt_startshourfraction(.runspec = .runspec)
adapt_starts(.runspec = .runspec)
adapt_startsperday(.runspec = .runspec)
adapt_startsperdaypervehicle(.runspec = .runspec)

source("scripts/adapt_startsopmodedistribution.R")
adapt_startsopmodedistribution(.runspec = .runspec)


## HOTELLING ############################################
cat("\n\n---HOTELLING TABLES-----------------------\n")
source("scripts/adapt_hotellingactivitydistribution.R")
adapt_hotellingactivitydistribution(.runspec = .runspec)


## IDLING ##############################################
cat("\n\n---IDLING TABLES--------------------------\n")
source("scripts/adapt_totalidlefraction.R")
adapt_totalidlefraction(.runspec = .runspec)

## IM PROGRAMS ##########################################
cat("\n\n---IM PROGRAM TABLES------------------------\n")
source("scripts/adapt_imcoverage.R")
adapt_imcoverage(.runspec = .runspec)

## CLIMATE ##############################################
cat("\n\n---CLIMATE TABLES---------------------------\n")
source("scripts/adapt_zonemonthhour.R")
adapt_zonemonthhour(.runspec = .runspec)


## CLEANUP ############################################
gc() # clear cache
cat("\n---done!---------------------------\n")


# Close
q(save = "no")

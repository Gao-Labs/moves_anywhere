# importer.R
# Function for creating an importer .xml script to make a custom input database.

# Debugging 
# setwd(paste0(rstudioapi::getActiveProject(), "/moves_anywhere"))

create_importer = function(BUCKET = "/cat/inputs", SOURCE= "scripts", dir = "/cat"){
  library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
  library(readr, warn.conflicts = FALSE, quietly = TRUE)
  library(xml2, warn.conflicts = FALSE, quietly = TRUE)
  
  # for debugging only
  # BUCKET = "inputs_ny"
  # BUCKET = "inputs"
  # SOURCE = "scripts"
  # Get the template importer
  
  rs = paste0(BUCKET, "/rs_custom.xml") %>% 
    xml2::read_xml() %>% as_list()
  
  imp = paste0(SOURCE, "/importer_template.xml") %>%
    xml2::read_xml() %>%
    as_list()
  
  
  # Use the run-spec sections to just directly overwrite portions of the template importer
  imp$moves$importer$filters$geographicselections = rs$runspec$geographicselections
  imp$moves$importer$filters$timespan = rs$runspec$timespan
  imp$moves$importer$filters$onroadvehicleselections = rs$runspec$onroadvehicleselections
  imp$moves$importer$filters$offroadvehicleselections = rs$runspec$offroadvehicleselections
  imp$moves$importer$filters$offroadvehiclesccs = rs$runspec$offroadvehiclesccs
  imp$moves$importer$filters$roadtypes = rs$runspec$roadtypes
  imp$moves$importer$filters$pollutantprocessassociations = rs$runspec$pollutantprocessassociations
  
  imp$moves$importer$databaseselection = imp$moves$importer$databaseselection %>%
    `attr<-`(which = "servername", value = attr(rs$runspec$scaleinputdatabase, "servername") )
  imp$moves$importer$databaseselection = imp$moves$importer$databaseselection %>% 
    `attr<-`(which = "databasename", value = attr(rs$runspec$scaleinputdatabase, "databasename") )
  
  fix_path = function(path){ paste0(dir, "/", path) }
  
  # if these files are present, load in their file paths...
  
  path = paste0(BUCKET, "/", "_sourcetypeagedistribution.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$agedistribution$parts$sourceTypeAgeDistribution$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_avgspeeddistribution.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$avgspeeddistribution$parts$avgSpeedDistribution$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_fuelsupply.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$fuel$parts$FuelSupply$filename = list(path)
  }

  path = paste0(BUCKET, "/", "_fuelformulation.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$fuel$parts$FuelFormulation$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_fuelusagefraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$fuel$parts$FuelUsageFraction$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_avft.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$fuel$parts$AVFT$filename = list(path)
  }
  
  
  
  path = paste0(BUCKET, "/", "_zonemonthhour.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$zonemonthhour$parts$zoneMonthHour$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_roadtypedistribution.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$roadtypedistribution$parts$roadTypeDistribution$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_sourcetypeyear.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$sourcetypepopulation$parts$sourceTypeYear$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_starts.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$starts$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_startsopmodedistribution.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsOpModeDistribution$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_startsageadjustment.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsAgeAdjustment$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_startsmonthadjust.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsMonthAdjust$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_startshourfraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsHourFraction$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_startsperday.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsPerDay$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_startsperdaypervehicle.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$starts$parts$startsPerDayPerVehicle$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_hpmsvtypeyear.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$vehicletypevmt$parts$HPMSVtypeYear$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_sourcetypeyearvmt.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$vehicletypevmt$parts$SourceTypeYearVMT$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_monthvmtfraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$vehicletypevmt$parts$monthVMTFraction$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_dayvmtfraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$vehicletypevmt$parts$dayVMTFraction$filename = list(path)
  }
  path = paste0(BUCKET, "/", "_hourvmtfraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$vehicletypevmt$parts$hourVMTFraction$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_hotellinghoursperday.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$hotelling$parts$hotellingHoursPerDay$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_hotellinghourfraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$hotelling$parts$hotellingHourFraction$filename = list(path)
  }
  path = paste0(BUCKET, "/", "_hotellingagefraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$hotelling$parts$hotellingAgeFraction$filename = list(path)
  }
  path = paste0(BUCKET, "/", "_hotellingmonthadjust.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$hotelling$parts$hotellingMonthAdjust$filename = list(path)
  }
  path = paste0(BUCKET, "/", "_hotellingactivitydistribution.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$hotelling$parts$hotellingActivityDistribution$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_totalidlefraction.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$idle$parts$totalIdleFraction$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_idlemodelyeargrouping.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$idle$parts$idleModelYearGrouping$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_idlemonthadjust.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$idle$parts$idleMonthAdjust$filename = list(path)
  }
  
  
  path = paste0(BUCKET, "/", "_idledayadjust.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$idle$parts$idleDayAdjust$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_imcoverage.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$imcoverage$parts$IMCoverage$filename = list(path)
  }
  
  path = paste0(BUCKET, "/", "_onroadretrofit.csv")
  if(file.exists(path)){
    path = fix_path(path)
    imp$moves$importer$onroadretrofit$parts$onRoadRetrofit$filename = list(path)
  }
  
  # path = paste0(BUCKET, "/", "_.csv")
  # if(file.exists(path)){
  #   imp$moves$importer$generic$parts$anytable$tablenamefilename = list(path)
  # }
  
  
  pathoutput = paste0(BUCKET, "/importer.xml")
  imp %>%
    xml2::as_xml_document() %>%
    readr::write_lines(file = pathoutput)

  return(pathoutput)
}

#' @name translate_rs
#' @title `translate_rs()`
#' @description ...
#' @param .runspec ...
#' @importFrom xml2 read_xml as_list 
#' @importFrom dplyr `%>%` tibble filter mutate n
#' @importFrom purrr map_chr
#' @export

translate_rs = function(.runspec = Sys.getenv("RS_TEMPLATE")){
  # Tim Fraser, Spring 2023
  
  # A function that translates a runspec file into a simplified, 
  # short R list of inputs describing key information from the runspec.
  # Useful for piping to adapt()
  
  # Testing values
  # require(xml2)
  # require(dplyr)
  # .runspec = "data_raw/rs_template.xml"
  # .runspec = "rs4.xml"
  
  x = read_xml(.runspec) %>% as_list()
  
  # Get mode (inventory or rate)
  .mode = attr(x$runspec$modelscale, "value") %>% tolower()
  
  # Get all geographies listed
  geo = x$runspec$geographicselections
  g = tibble(var = geo %>% names()) %>% mutate(id = 1:n()) %>%
    filter(var == "geographicselection") %>% with(id) %>% geo[.]
  .geoid = g %>%  purrr::map_chr(~attr(., "key")) %>% unname()

  
  remove(geo, g)

  # Get output aggregation level
  .level = x$runspec$geographicoutputdetail %>% attr("description") %>% tolower()

    
  # Get all pollutants listed
  pol = x$runspec$pollutantprocessassociations
  .pollutant = 1:length(pol) %>%
    purrr::map_chr(~pol[.]$pollutantprocessassociation %>% attr("pollutantkey")) %>%
    unique() %>% as.integer()
  
  remove(pol)
  
  # Get all times listed  
  time = x$runspec$timespan
  
  t = tibble(var = time %>% names()) %>% mutate(id = 1:n())
  
  .year = t %>% filter(var == "year") %>% with(id) %>% time[.] %>%
    purrr::map_chr(~attr(., "key"))  %>% unname() %>% as.integer()
  
  .month = t %>% filter(var == "month") %>% with(id) %>% time[.] %>%
    purrr::map_chr(~attr(., "id"))  %>% unname() %>% as.integer()
  
  .day = t %>% filter(var == "day") %>% with(id) %>% time[.] %>%
    purrr::map_chr(~attr(., "id")) %>% unname() %>% as.integer()
  
  .beginhour = t %>% filter(var == "beginhour") %>% with(id) %>% time[.] %>%
    purrr::map_chr(~attr(., "id")) %>% unname() %>% as.integer()
  .endhour = t %>% filter(var == "endhour") %>% with(id) %>% time[.] %>%
    purrr::map_chr(~attr(., "id")) %>% unname() %>% as.integer()
  
  .hour = min(.beginhour):max(.endhour)
  
  remove(t, time)
  
  # Get all sourcetypes listed #################################
  .fueltype = x$runspec$onroadvehicleselections %>%
    map_chr(~.x %>% attr("fueltypeid")) %>%
    unique() %>% as.integer() %>% sort()
  
  # Get all fueltypes listed #################################
  .sourcetype = x$runspec$onroadvehicleselections %>%
    map_chr(~.x %>% attr("sourcetypeid")) %>%
    unique() %>% as.integer() %>% sort()
  
  # Get all roadtypes listed #######################################
  .roadtype = x$runspec$roadtypes %>%
    map_chr(~.x %>% attr("roadtypeid")) %>%
    unique() %>% as.integer() %>% sort()
  
  # AGGREGATION ################################
  # Get time aggregation level
  .timeaggregation1 = x$runspec$timespan$aggregateBy %>% attr("key") %>% tolower()
  .timeaggregation2 = x$runspec$outputtimestep %>% attr("value") %>% tolower()
  .timeaggregation3 = x$runspec$outputfactors$timefactors %>% attr("units") %>% tolower()
  # Time aggregation must be the same in each for us to grab it.
  check_time = .timeaggregation1 == .timeaggregation2 &
    .timeaggregation1 == .timeaggregation3 &
    .timeaggregation2 == .timeaggregation3
  # If they are the same, assign
  if(check_time == TRUE){
    .timeaggregation = .timeaggregation1
  }else{ .timeaggregation = NULL }

  # Get geographic aggregation level
  .geoaggregation = x$runspec$geographicoutputdetail %>% attr("description") %>% tolower()

  # INPUT/OUTPUT DATABASE TRAITS  
  .inputservername = x$runspec$scaleinputdatabase %>% attr(., "servername")
  .inputdbname = x$runspec$scaleinputdatabase %>% attr(., "databasename")
  
  .outputservername = x$runspec$outputdatabase %>% attr(., "servername")
  .outputdbname = x$runspec$outputdatabase %>% attr(., "databasename")
  
  .default = if(attr(x$runspec$modeldomain, "value") == "SINGLE"){ FALSE }else{ TRUE }

  result = list(geoid = .geoid, level = .level,
                pollutant = .pollutant, 
                year = .year, month = .month, day = .day, hour = .hour,
                sourcetype = .sourcetype, fueltype = .fueltype, roadtype = .roadtype, 
                default = .default,
                inputservername = .inputservername,
                inputdbname = .inputdbname,
                outputservername = .outputservername,
                outputdbname = .outputdbname,
                mode = .mode,
                geoaggregation = .geoaggregation,
                timeaggregation = .timeaggregation
              )
  
  return(result)
}



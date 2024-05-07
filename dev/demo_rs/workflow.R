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
rs$runspec$pollutantprocessassociations[[1]]

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



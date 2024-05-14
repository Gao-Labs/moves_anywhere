# xml_to_json.R

# Testing only
# setwd(rstudioapi::getActiveProject())
# setwd("image_xml_to_json")

folder = "inputs/"
file_xml = "rs_custom.xml"
path_xml = paste0(folder, "/", file_xml)

library("xml2", warn.conflicts = FALSE, quietly = TRUE)
library("jsonlite", warn.conflicts = FALSE, quietly = TRUE)
library("dplyr", warn.conflicts = FALSE, quietly = TRUE)
library("purrr", warn.conflicts = FALSE, quietly = TRUE)

# Read in xml file
source("translate_rs.R")
# Translate runspec xml into json list object
mylist = translate_rs(path_xml)

# Format
myjson = toJSON(mylist, pretty = TRUE, auto_unbox = TRUE)

# Write to file
cat(myjson, file = "inputs/translation.json")


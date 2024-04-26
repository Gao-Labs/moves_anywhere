library(catr)

setwd(rstudioapi::getActiveProject())
setwd("image_moves")

# Try what we really want
catr::custom_rs(
  .geoid = "36109", .year = 2025, .level = "county", .default = FALSE,.path = "volume_rate/rs_custom.xml", 
  .rate = TRUE, .geoaggregation = "county", .timeaggregation = "year"
)


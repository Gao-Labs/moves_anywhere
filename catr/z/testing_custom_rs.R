# testing_custom_rs.R
# 4/25/2024

# Let's test and make sure custom_rs works as expected.

setwd(rstudioapi::getActiveProject())
setwd("catr")

devtools::document()
devtools::load_all()

custom_rs(
  .geoid = "36109", .year = 2020, .level = "county", .default = FALSE, .path = "z/test_1.xml",
  .rate = TRUE, 
  .geoaggregation = "link",
  .timeaggregation = "hour"
)


custom_rs(
  .geoid = "36109", .year = 2020, .level = "county", .default = FALSE, .path = "z/test_2.xml",
  .rate = TRUE, 
  .geoaggregation = "county",
  .timeaggregation = "year"
)


custom_rs(
  .geoid = "36109", .year = 2020, .level = "county", .default = FALSE, .path = "z/test_3.xml",
  .rate = FALSE, 
  .geoaggregation = "county",
  .timeaggregation = "year"
)

#' @name fieldtypes.r
#' @title fieldtypes for MySQL database table upload.
#' @description
#' Gets loaded with `source("fieldtypes.r")` in the `postprocess_upload.r` script,
#' and gets passed to the `upload()` function there as an input argument.
#' If you need to use different fieldtypes, you can mount to the image a different `fieldtypes.r` file.

fieldtypes = c(
  by = "tinyint(2)",
  year = "smallint(4)",
  geoid = "char(5)",
  pollutant = "tinyint(3)",
  sourcetype = "tinyint(2)",
  regclass = "tinyint(2)",
  fueltype = "tinyint(1)",
  roadtype = "tinyint(1)",
  emissions = "double(18,1)",
  vmt = "double(18,1)",
  sourcehours = "double(18,1)",
  vehicles = "double(18,1)",
  starts = "double(18,1)",
  idlehours = "double(18,1)",
  hoteld = "double(18,1)",
  hotelb = "double(18,1)",
  hotelo = "double(18,1)")

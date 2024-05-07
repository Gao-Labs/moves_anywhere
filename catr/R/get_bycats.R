#' @name get_bycats
#' @title Get `by` category variables
#' @description
#' Returns a vector of columns corresponding to a given `by` value
#' @param .by integer id for aggregation level
#' @export
get_bycats = function(.by){
  cats = switch(
    EXPR = .by,
    "1" = c("sourcetype", "regclass", "fueltype", "roadtype"),
    "2" = c("sourcetype", "regclass", "fueltype"),
    "3" = c("sourcetype", "regclass", "roadtype"),
    "4" = c("sourcetype", "regclass"),
    "5" = c("sourcetype", "fueltype", "roadtype"),
    "6" = c("sourcetype", "fueltype"),
    "7" = c("sourcetype", "roadtype"),
    "8" = c("sourcetype"),
    "9" = c("regclass", "fueltype", "roadtype"),
    "10" = c("regclass", "fueltype"),
    "11" = c("regclass", "roadtype"),
    "12" = c("regclass"),
    "13" = c("fueltype", "roadtype"),
    "14" = c("fueltype"),
    "15" = c("roadtype"),
    "16" = c()
  )
  return(cats)
}
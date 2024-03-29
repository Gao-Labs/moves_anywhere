% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_moves.R
\name{format_moves}
\alias{format_moves}
\title{Format Data into CAT Format}
\usage{
format_moves(
  path = "data.rds",
  by = NULL,
  pollutant = NULL,
  path_parameters = "inputs/parameters.json"
)
}
\arguments{
\item{path}{(character) path to .rds file containing table, on docker container
Advanced Parameters - only for use if you really need them. Otherwise, just change `inputs/parameters,json`}

\item{by}{(integer) vector of aggregation levels. Default is NULL, which defaults to levels specified in the `inputs/parameters.json`.}

\item{pollutant}{(integer) vector of pollutants to return. Default is NULL, which defaults to pollutants specified in the `inputs/paramters.json`}

\item{path_parameters}{path to inputs/parameters.json file}
}
\description{
Format Data into CAT Format
}
\author{
Tim Fraser
}

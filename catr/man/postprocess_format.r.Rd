% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/postprocess_format.R
\name{postprocess_format.r}
\alias{postprocess_format.r}
\alias{postprocess_format}
\title{postprocessing code for formatting run AFTER invoking MOVES}
\usage{
postprocess_format(
  path_data = "data.rds",
  csv = FALSE,
  by = NULL,
  pollutant = NULL,
  path_parameters = "inputs/parameters.json"
)
}
\arguments{
\item{path_data}{path to output data file}

\item{csv}{(logical) Should it be outputted as a .csv or a .rds file? If TRUE, as a `.csv`. If FALSE, as a `.rds` file. Defaults to `.rds` for easy smaller storage.
Usually don't need to specify these}

\item{by}{(integer) Defaults to `NULL`. If `NULL`, uses the `by` values from the parameters.json supplied.}

\item{pollutant}{(integer) Defaults to `NULL`. If `NULL`, uses the `pollutant` values from the parameters.json supplied.}

\item{path_parameters}{path to inputs/parameters.json file}
}
\description{
postprocessing code for formatting run AFTER invoking MOVES
}
\author{
Tim Fraser & colleagues
}

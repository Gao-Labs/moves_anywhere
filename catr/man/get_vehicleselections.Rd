% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_vehicleselections.R
\name{get_vehicleselections}
\alias{get_vehicleselections}
\title{Get Onroad Vehicle Selections in bulk in Runspec format}
\usage{
get_vehicleselections(.sourcetypes = NULL, .fueltypes = NULL)
}
\arguments{
\item{.sourcetypes}{(integer) integer vector of `sourceTypeID`s that you want to filter by. Leave blank (`NULL`) to use all.}

\item{.fueltypes}{(integer) integer vector of `fuelTypeID`s that you want to filter by. Leave blank (`NULL`) to use all.}
}
\description{
Depending on vehicles selected, gets **all** fueltypes available.
}
\examples{
# All possible, valid sourcetype-fueltype combinations
get_vehicleselections()

# Electric passenger cars only
get_vehicleselections(.sourcetype = 21, .fueltype = 9)

}
\author{
Tim Fraser
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/custom_rs.R
\name{custom_rs}
\alias{custom_rs}
\title{`custom_rs()` function}
\usage{
custom_rs(
  .geoid = "36109",
  .year = 2020,
  .level = "county",
  .default = FALSE,
  .id = 1,
  .dir = NULL,
  .outputdbname = "moves",
  .outputservername = "localhost",
  .inputdbname = "movesdb20240104",
  .inputservername = "localhost"
)
}
\arguments{
\item{.geoid}{description TBA.}

\item{.year}{description TBA.}

\item{.level}{description TBA.}

\item{.default}{description TBA.}

\item{.id}{description TBA.}

\item{.dir}{Directory where runspec outputs}

\item{.outputdbname}{Output database name}

\item{.outputservername}{Hostname of output database (defaults to localhost)}

\item{.inputdbname}{Custom Input database name}

\item{.inputservername}{Hostname of custom input database (defaults to localhost)}
}
\description{
Designs a custom runspec file based off input parameters.
eg. custom_rs(.geoid = "36109", .year = 2020, .level = "county", .default = FALSE)
}

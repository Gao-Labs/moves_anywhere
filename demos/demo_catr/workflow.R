#' @name workflow.R
#' @description
#' A description of how to install the catr package!

# Open an R session

# Be sure to have installed devtools already
# install.packages("devtools")

# Load devtools
library(devtools)

# Remove catr if you already have it; if not skip this step
unloadNamespace("catr"); remove.packages("catr")

# Install from github
devtools::install_github(repo = "gao-labs/moves_anywhere", subdir = "catr")

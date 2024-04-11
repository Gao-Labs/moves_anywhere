#' @name dev.R
#' @title DEVELOPMENT SCRIPT for catr
#' @author Tim Fraser
#'
#' @description A script to build our R package
#' 

# Assume working directory is the project/package directory.
unloadNamespace(ns = "catr"); rm(list = ls())
remove.packages("catr")
# Set working directory to project directory
# getwd()
# setwd("../moves_anywhere/catr")
setwd(rstudioapi::getActiveProject())
# Zoom into catr directory
setwd("./catr")
# Check directory
getwd()
# Document package
devtools::document()

# Build quick package
devtools::build(path = ".", pkg = getwd(), binary = FALSE, manual = TRUE, vignettes = FALSE)
# Get package name
package = "catr_0.1.0.tar.gz"
# Copy package to image file
file.copy(from = package, to = paste0("../image/", package), overwrite = TRUE)

# Unload catr if installed or loaded
unloadNamespace(ns = "catr"); remove.packages("catr")

# Install catr
install.packages(package, type = "source")


# Load catr
# library(catr)

# Clean up
rm(list = ls()); gc()

# Tidy up your description file
usethis::use_tidy_description()


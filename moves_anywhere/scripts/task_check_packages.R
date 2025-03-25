# status_check.R

# Script to check if all necessary packages are installed.

# Get installed packages
p = as.data.frame(installed.packages())

# Which of these packages do we have?
needed = c("lubridate", "dplyr", "readr", 
           "purrr",  "tidyr", "stringr", 
           "DBI", "dbplyr", "RMariaDB", "RMySQL",
           "googleCloudStorageR",
           "remotes",
           "googleAuthR",
           "gargle",
           "httr",
           "jsonlite",
           "xml2",
           "catr"
)

# Are there any packages that are needed but are not installed?
remaining = needed[!needed %in% p$Package]

n_remaining = length(remaining)

if(n_remaining > 0){
  cat("---", n_remaining, " R packages need installed: ", paste0(remaining, collaspse = ", "), "\n")
}else{
  cat("---R packages ready.\n")
}

# Close R
q(save = "no")


# task_install_catr.R

# Script to install catr

# Runtime Variables
FOLDER="/cat/"

# Set working directory to /cat/
setwd(FOLDER)

# Install package from source
install.packages("scripts/catr_0.2.0.tar.gz", type = "source")

# Print the package version of catr
cat(paste0("\n---catr version: ", packageVersion("catr"), "\n"))

# Close out
q(save = "no")
#!/bin/bash

# Script to Run on Startup
# when new docker container is made

# Uploads Data from a Bucket to Database

# Print working directory
pwd;

# Run upload post-processing (where applicable. Requires a mounted .Renviron file)
Rscript postprocess_upload.r

# End script
bash
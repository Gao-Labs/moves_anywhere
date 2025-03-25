#!/bin/bash

# launch.sh

# A script to run MOVES ANYWHERE at launch.

# Check for contents of inputs folder
. "scripts/task_check_inputs.sh"

# Check for contents of inputs folder
. "scripts/task_copy_runspec.sh"


# Check if all R packages are installed.
Rscript "scripts/task_install_catr.R"

# Check if all R packages are installed.
Rscript "scripts/task_check_packages.R"

# Start up mysql
. "scripts/task_start_mysql.sh"

# Initiate the adapt protocol
# Rscript "scripts/task_adapt.R"
Rscript "scripts/task_adapt.R"

# Create custom database
Rscript "scripts/task_db_create.R"

# Import tables into newly created database
. "scripts/task_importer.sh"

# Copy MOVES logs into inputs bucket
. "scripts/task_launch_moves.sh"


# Postprocess MOVES output data in R
Rscript "scripts/task_postprocess.R"

# Copy MOVES logs into inputs bucket
. "scripts/task_copy_logs.sh"

# Summarize results quickly for diagnostics
Rscript "scripts/task_summarize.R"

# Finishup
exit 0 # Exit without error

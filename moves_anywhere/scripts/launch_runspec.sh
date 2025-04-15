#!/bin/bash

# launch_runspec.sh

# A script to make a runspec with MOVES ANYWHERE at launch.

# Check for contents of inputs folder
# . "scripts/task_check_inputs.sh"

# Check for contents of inputs folder
# . "scripts/task_copy_runspec.sh"

# Check if all R packages are installed.
# Rscript "scripts/task_install_catr.R"

# Check if all R packages are installed.
Rscript "scripts/task_check_packages.R"

# Create the runspec
Rscript "scripts/task_runspec.R"

# Finishup
exit 0 # Exit without error

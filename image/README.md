# README `moves_anywhere:v1`

- Description: This folder is the home to efforts to make a PRIVATE `moves_anywhere_plus` Docker Image, which implements the upload functions for CATSERVER.
- Author: Tim Fraser (tmf77@cornell.edu)
- Contributors to `moves_anywhere`: Erin Murphy, Junna Chen

# Table of Contents

## Files

### Files for Building the Image

- `dockerfile`: Instructions to build the docker image.
- `.dockerignore`: Files to ignore. (No edits needed here.)
- `launch_plus.sh`: Upgraded version of `launch.sh` that runs MOVES, CAT-formats the data, and *also* uploads it. Run this, not `launch.sh` in the container.
- `upload.r`: function to upload data to CATSERVER.
- `postprocess_upload.r`: script for managing upload process.
- `check.r`: script for checking if upload was successful.
- `.Renviron`: you need to make this! You need an `.Renviron` file containing `ORDERDATA_USERNAME`, `ORDERDATA_PASSWORD`, `ORDERDATA_HOST` and `ORDERDATA_PORT`. The username should be `userapi`, with read-write access to CATSERVER's `orderdata` db. If you have been granted access, you can view those credentials on [**this Google Doc**](https://docs.google.com/document/d/1ZA-Q5pPdhPyOwZrjfHl99TfyRz67P2BN245LV4TydvQ/edit?usp=sharing).**

### Files for Running a Container

- `README.md`: General information (you're here!)
- `demo.sh`: shell script demoing how to build the image and running a container
- `demo1_inputs/*`: folder of `parameters.json` and various `.csv` input files. Gets mounted to the container.
- `demo1_inputs/parameters.json`: contains 2 EXTRA VALUES compared to normal `moves_anywhere` run. These include `dtablename` (name of `orderdata` table to create/edit) and `multiple` (are multiple years of data getting run?)

### FAQs (Frequently Asked Questions)

- If you edit `launch_plus.sh` on a windows machine, you'll probably need to run `dos2unix launch_plus.sh` in order for the linux container to read it properly.
- Add here...


### How does MOVES Anywhere work anyways?

- write a runspec from parameters --> `catr/R/custom_rs.R`
- write custom tables into a moves input database --> `images/adapt.r`, formerly `catr/R/adapt.r`


- default database
- output database
- input database


- default database --> overwrite tables with .csvs from the inputs/ folder (adapt.r)
- default database --> for every table not uploaded, go and adapt it to be the right filters, etc. (adapt.r)


`image/launch.sh` runs several scripts
  - turns on MySQL in the container
  - `image/preprocess.r`: run a pre-processing script
      - load R packages
      - `image/setenv.r` sets environmental variables
      - imports parameters from `inputs/parameters.json`
      - uses `catr::custom_rs()` to make a runspec  (see `catr/R/custom_rs`)
      - writes a runsepc to `inputs/rs_custom.xml`
      - `image/adapt.r` - imports a set of .csvs from `inputs/XXXX.csv` and the `inputs/rs_custom.xml`
      
`catr/R/custom_rs.R`
  - grabs a list object saved in `catr/data/rs_template.rda`
  - tweaks it using just a few inputs, like `.geoid`, `.year`, `.level`, `.default`, .`id`, and input/output database names and stuff.
  



















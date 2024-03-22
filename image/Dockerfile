# FROM ubuntu:20.04

# RUN mkdir cat-api

# Create and change to this directory
# WORKDIR cat-api

# Set environment variable so apt-get runs without interactive dialogue
# ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
# RUN apt-get update && apt-get install -y \
#    r-base \
#    mariadb-server \
#    openjdk-11-jdk \
#    golang-go \
#    git \
#    ant \
#    unzip \
#    sudo \
#    libmariadb-dev \
#    libxml2-dev \
#    r-cran-dplyr \
#    r-cran-readr \
#    r-cran-jsonlite \
#    r-cran-dbi \
#    r-cran-xml2


# Clone the EPA MOVES Model repository
# RUN git clone https://github.com/USEPA/EPA_MOVES_Model.git

# Unzip database dumpfile
# RUN unzip EPA_MOVES_Model/database/Setup/movesdb20240104.zip -d EPA_MOVES_Model/database/Setup

# Install More R Packages
# RUN R -e "install.packages('RMariaDB', repo = 'http://cran.rstudio.com/')"
# RUN R -e "install.packages('RMySQL', repo = 'http://cran.rstudio.com/')"
# RUN R -e "install.packages('purrr', repo = 'http://cran.rstudio.com/')"
# RUN R -e "install.packages('tidyr', repo = 'http://cran.rstudio.com/')"
# RUN R -e "install.packages('dbplyr', repo = 'http://cran.rstudio.com/')"
# RUN R -e "install.packages('vroom', repo = 'http://cran.rstudio.com/')"

# Copy your files to the container
# COPY setenv.sh /cat-api/EPA_MOVES_Model
# Setting mysql/mariadb configurations based on MOVES repository README
# COPY my.cnf /etc/my.cnf

# Giving group permissions recursively to /cat-api and giving mysql ownership recursively
# RUN chown -R mysql:mysql /cat-api
# RUN chmod -R 6777 /cat-api

# Setup Databases
# COPY setupdb.sh /cat-api/setupdb.sh
# Make setupdb.sh executable
# RUN chmod +x /cat-api/setupdb.sh
# SHELL ["/bin/bash", "-c"]
# RUN /cat-api/setupdb.sh

# Build ontop of tmf77/docker_moves:v1, whose layers are written above
FROM tmf77/docker_moves:v1

WORKDIR /cat-api
# COPY . /cat-api

# Install catr from source #####################################
# RUN R -e "install.packages('readxl')"
COPY "catr_0.1.0.tar.gz" "/cat-api/catr_0.1.0.tar.gz"
RUN R -e "install.packages('catr_0.1.0.tar.gz', type = 'source'); print(packageVersion('catr'))"

# COPY /context /cat-api/context
COPY setenv.sh /cat-api/setenv.sh
COPY setenv.r /cat-api/setenv.r
COPY preprocess.r /cat-api/preprocess.r
COPY postprocess.r /cat-api/postprocess.r

# Copy upload.r, the function script that uploads to CATSERVER
COPY upload.r /cat-api/upload.r
# Copy postprocess_upload.r, the script that calls upload.r
COPY postprocess_upload.r /cat-api/postprocess_upload.r
# Copy check.r, the script that checks if upload was successful.
COPY check.r /cat-api/check.r

# Launch MOVES 
COPY launch.sh /cat-api/launch.sh
RUN chmod +x /cat-api/launch.sh

# Set working directory of image
WORKDIR /cat-api

# Make inputs folder be mountable
VOLUME /cat-api/inputs

# To upload to CATSERVER (optional, just for advanced use),
# You can mount an .Renviron file with CATSERVER write credentials (sensitive!)
# note: you will need to add this file yourself. Looks like:
# ORDERDATA read-write credentials
# ORDERDATA_USERNAME="******************"
# ORDERDATA_PASSWORD="******************"
# ORDERDATA_HOST="****************"
# ORDERDATA_PORT="****"
VOLUME /cat-api/.Renviron

# Optional: Use launch.sh as the entrypoint
# ENTRYPOINT [ "/cat-api/launch.sh" ]

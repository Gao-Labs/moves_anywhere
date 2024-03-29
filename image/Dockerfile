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


# Copy other items that might change often
# COPY /inputs /cat-api/inputs
VOLUME /cat-api/inputs

# Give recursive powers to the whole folder
# RUN chown -R mysql:mysql /cat-api
# RUN chmod -R 6777 /cat-api

# Launch MOVES 
COPY launch.sh /cat-api/launch.sh
RUN chmod +x /cat-api/launch.sh

# Use launch.sh as the entrypoint
# ENTRYPOINT [ "/cat-api/launch.sh" ]

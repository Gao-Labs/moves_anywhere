FROM ubuntu:20.04

# Label the image
LABEL title="docker-moves"
LABEL description="docker-moves image for customized MOVES estimation on any OS"
LABEL version="2.0"
LABEL maintainer="Tim Fraser"
LABEL org.opencontainers.image.authors="tmf77@cornell.edu"

# Create directory
RUN mkdir cat

# Create and change to this directory
WORKDIR cat

# Set environment variable so apt-get runs without interactive dialogue
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    mariadb-server \
    openjdk-11-jdk \
    golang-go \
    git \
    ant \
    unzip \
    sudo \
    libmariadb-dev \
    libxml2-dev

# Upgrade R
# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    gnupg \
    curl

# Add R repository and install the latest R version
RUN curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /usr/share/keyrings/cran-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | tee /etc/apt/sources.list.d/cran.list && \
    apt-get update && \
    apt-get install -y r-base

# Install next dependencies
# RUN apt-get update && apt-get install -y \
#     r-cran-dplyr \
##    r-cran-readr \
#    r-cran-jsonlite \
#    r-cran-dbi \
#    r-cran-xml2


# Install new R dependencies
RUN R -e "install.packages('remotes', repos = 'http://cran.us.r-project.org')"

# Install More R Packages
RUN R -e "remotes::install_version('dplyr', version = '1.1.0', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('readr', version = '2.1.4', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('tidyr', version = '1.3.0', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('purrr', version = '1.0.1', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('lubridate', version = '1.9.2', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('stringr', version = '1.5.0', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('vroom', version = '1.6.3', repos = 'http://cran.us.r-project.org')"

RUN R -e "remotes::install_version('xml2', version = '1.3.6', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('jsonlite', version = '1.8.9', repos = 'http://cran.us.r-project.org')"

RUN R -e "remotes::install_version('dbplyr', version = '2.3.2', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_version('RMariaDB', version = '1.3.1', repos = 'http://cran.us.r-project.org')"


# Try again for core ones
RUN R -e "install.packages('RMySQL', repos = 'http://cran.us.r-project.org'); packageVersion('RMySQL')"

# Install dependencies for gargle
RUN apt-get update && apt-get install -y \
  libssl-dev
  
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  wget


RUN R -e "install.packages('httr', repos = 'http://cran.us.r-project.org'); packageVersion('httr');"
RUN R -e "install.packages('gargle', repos = 'http://cran.us.r-project.org'); packageVersion('gargle');"
RUN R -e "install.packages('googleAuthR', repos = 'http://cran.us.r-project.org'); packageVersion('googleAuthR');"
RUN R -e "install.packages('googleCloudStorageR', repos = 'http://cran.us.r-project.org'); packageVersion('googleCloudStorageR');"

# RUN R -e "remotes::install_version('RMySQL', version = '0.10.25', repos = 'http://cran.us.r-project.org')"
# RUN R -e "remotes::install_version('gargle', version = '1.5.2', repos = 'http://cran.us.r-project.org')"
# RUN R -e "remotes::install_version('googleCloudStorageR', version = '0.7.0', repos = 'http://cran.us.r-project.org')"
# RUN R -e "remotes::install_version('googleAuthR', version = '2.0.1', repos = 'http://cran.us.r-project.org')"
# RUN R -e "remotes::install_version('httr', version = '1.4.7', repos = 'http://cran.us.r-project.org')"


# Clone the EPA MOVES Model repository
RUN git clone https://github.com/USEPA/EPA_MOVES_Model.git

# Unzip database dumpfile
RUN unzip EPA_MOVES_Model/database/Setup/movesdb20241112.zip -d EPA_MOVES_Model/database/Setup

# Copy your files to the container
COPY setenv.sh /cat/EPA_MOVES_Model
# Setting mysql/mariadb configurations based on MOVES repository README
COPY my.cnf /etc/my.cnf

# Giving group permissions recursively to /cat and giving mysql ownership recursively
RUN chown -R mysql:mysql /cat
RUN chmod -R 6777 /cat

# Setup Databases 
COPY setupdb.sh /cat/setupdb.sh
# Make setupdb.sh executable
RUN chmod +x /cat/setupdb.sh
SHELL ["/bin/bash", "-c"]
RUN /cat/setupdb.sh


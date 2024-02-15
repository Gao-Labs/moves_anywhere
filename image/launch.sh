#!/bin/bash

# Script to Run on Startup
# when new docker container is made

# Print working directory
pwd;

# 1. Start MySQL Service #############################
echo -----------starting MySQL service----------------
service mysql start

# Wait for mysql to start up
while ! mysqladmin ping --silent; do
    sleep 1
done


# # 2. Pre-Processing #########################################################################
Rscript preprocess.r


# Run any extra importers
echo -----------running other importers----------------
cd EPA_MOVES_Model
# mysql -uroot -pmvoes moves < database/AVFTImporter.sql
  # NEW_DB_NAME="movesdb20240104"
  # sed "s/##defaultdb##/${NEW_DB_NAME}/g" database/CreateOutput.sql > database/NewCreateOutput.sql
  # mysql -uroot -pmoves moves < database/NewCreateOutput.sql
  # mysql -uroot -pmoves moves < database/CreateOutputRates.sql

cd ..

# 3. MOVES Setup ###################################
cd EPA_MOVES_Model

pwd;

# Editing MOVES Configuration generator path
echo ------------editing MOVESConfiguration.txt------------
sed -i 's|\\|/|g' MOVESConfiguration.txt


# Ensure that the output of these two match: 
#   which java should have the same path as $JAVA_HOME, but with /bin/java at the end
which java
echo $JAVA_HOME

# Compiling Java and Go files in MOVES
echo ------------compiling Java------------
ant clean
ant compileall
echo ------------compiling Go------------
ant go64


# Changing to mysql user and running the CUSTOM runspec
echo ------------running runspec------------
sudo -u mysql ant run -Drunspec="/cat-api/EPA_MOVES_Model/rs_custom.xml"

# Jump Backwards in File Directory, back to /cat-api/
cd ..

# # 3. Post-Processing #########################################################################
Rscript postprocess.r

bash
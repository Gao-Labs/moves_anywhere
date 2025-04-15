#!/bin/bash


# 1. Pre-MOVES #######################################################
pwd;


# 2. MYSQL ##########################################################################

# Start mysql
service mysql start

# Wait for mysql to start up
while ! mysqladmin ping --silent; do
    sleep 1
done

# Create moves db if it doesn't exist
echo "------------Checking if 'moves' exists...------------"
if ! mysql -e "USE moves"; then
    echo "------------Database 'moves' does not exist. Creating...------------"
    mysql -e "CREATE DATABASE moves CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    echo "------------Database 'moves' created.------------"
else
    echo "------------Database 'moves' already exists.------------"
fi

# Run the database setup scripts
echo ------------running database setup------------
cd EPA_MOVES_Model/database/Setup
chmod 777 ./SetupDatabase.bat
./SetupDatabase.bat

echo ------------running output database setup------------
cd ../..
NEW_DB_NAME="movesdb20241112"
sed "s/##defaultdb##/${NEW_DB_NAME}/g" database/CreateOutput.sql > database/NewCreateOutput.sql
mysql -uroot -pmoves moves < database/NewCreateOutput.sql
mysql -uroot -pmoves moves < database/CreateOutputRates.sql

# Modify and run setenv.bat file
echo ------------running setenv------------
chmod 777 ./setenv.sh
. ./setenv.sh

# End the setup process
service mysql stop

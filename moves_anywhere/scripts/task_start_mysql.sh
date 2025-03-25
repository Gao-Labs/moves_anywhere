#!/bin/bash

# task_start_mysql.sh

# Script to launch MySQL

# Start MySQL Service #############################
echo -----------starting MySQL service----------------
service mysql start

# Wait for mysql to start up
while ! mysqladmin ping --silent; do
    sleep 1
done




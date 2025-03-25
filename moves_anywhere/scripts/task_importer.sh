#/bin/bash
# task_importer.sh

# Script to import a set of files using an importer.xml

# MOVES Setup ###################################
cd "/cat/EPA_MOVES_Model" || { echo "Failed to change directory"; exit 1; }

# Editing MOVES Configuration generator path
echo ------------editing MOVESConfiguration.txt------------
sed -i 's|\\|/|g' MOVESConfiguration.txt


# Ensure debugdata is kept
sed -i 's/keepDebugData = false;/keepDebugData = true;/' gov/epa/otaq/moves/master/framework/OutputProcessor.java

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


# Changing to mysql user and running the custom database importer
echo ------------running importer------------
sudo -u mysql ant dbimporter -Dimport="/cat/inputs/importer.xml"

cd "/cat"

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

# Make importer executable
chmod +x /cat

# Grab the importer.xml from the bucket and copy it to my current working directory
# Copy the file out of the mounted directory
cp /cat/inputs/importer.xml /cat/EPA_MOVES_Model/importer.xml || {
    echo "🛑 Failed to copy importer.xml from mounted dir"; exit 1;
}

# Make sure mysql can read it
chown mysql:mysql /cat/EPA_MOVES_Model/importer.xml
chmod 777 /cat/EPA_MOVES_Model/importer.xml  # readable by mysql, not executable because it's an XML file

# Optional: Confirm access as mysql
echo "Verifying access to new importer file location..."
sudo -u mysql ls -l /cat/EPA_MOVES_Model/importer.xml || {
    echo "🛑 Error: mysql still can't read the copied file"; exit 1;
}

# Make importer executable
# chmod +x /cat
# chmod +x /cat/inputs
# chown mysql:mysql /cat/inputs/importer.xml
# chmod 755 /cat/inputs/importer.xml

# echo "Verifying file existence as root:"
# ls -l /cat/inputs/importer.xml

# Check if the importer.xml file exists and is readable by mysql
# echo "Verifying file /cat/inputs/importer.xml..."
# sudo -u mysql ls -l /cat/inputs/importer.xml || echo "⚠️ Warning: File might not be accessible"

echo "✅ Verifying key file exists:"
ls -l /cat/inputs/_sourcetypeagedistribution.csv


# Changing to mysql user and running the custom database importer
echo ------------running importer------------
sudo -u mysql bash -c 'ant dbimporter -Dimport="/cat/EPA_MOVES_Model/importer.xml"'

# Reset directory
cd "/cat"

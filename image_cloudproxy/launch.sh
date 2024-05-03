#!/bin/bash

# Script to Run on Startup
# when new docker container is made

# Uploads Data from a Bucket to Database

# Print working directory
pwd;

# In order for this to work, your docker image needs a few environmental variables
if [ -n "$DBHOST" ] && [ -n "$DBPORT" ] && [ -n "$DBINSTANCE" ] && [ -n "$DBNAME" ] && [ -n "$DBUSERNAME" ] && [ -n "$DBPASSWORD" ]; then

  echo "DBHOST, DBPORT, & DBINSTANCE, DBNAME, DBUSERNAME, & DBPASSWORD, variables are present."

  # ./cloud-sql-proxy --help
  # ./cloud-sql-proxy --json-credentials secret1/keyapi.json "$INSTANCE"
  # echo "$INSTANCE"
  # cp /secret1/keyapi.json ./cloud-sql-proxy/keyapi.json
  # 
  # Write a function to establish the cloud sql proxy
  db_proxy() {
    echo "Starting daemon..."
    ./cloud-sql-proxy \
       --credentials-file secret/runapikey.json \
       --address "$DBHOST" \
       --port $DBPORT \
       --run-connection-test \
       "$DBINSTANCE"
  }

  # Start the daemon
  db_proxy &

  echo "Postprocessing..."
  # Run upload post-processing (where applicable. Requires a mounted .Renviron file)
  # --vanilla --> run R without saving environment, etc.
  # --ess --> run R in a non-interactive environment
  Rscript --vanilla --ess postprocess_upload.r

else
    echo "An environmental variable is either not set or has length 0."
fi


# End script
bash


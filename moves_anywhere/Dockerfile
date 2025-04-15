FROM tmf77/docker_moves:v2

# ESTABLISH WORKING DIRECTORY
WORKDIR /cat

# Install gcloud CLI
# For information: https://cloud.google.com/sdk/docs/install#deb
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-cli -y

# Install gcsfuse CLI
RUN export GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s) && \
    echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" > /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y fuse gcsfuse && \
    gcsfuse -v

# COPY IN MATERIALS
COPY scripts ./scripts

# Make scripts executable
RUN chmod +x /cat/scripts/*.sh
# RUN chmod +x /cat/scripts/launch.sh
# RUN chmod +x /cat/scripts/launch_runspec.sh
# RUN chmod +x /cat/scripts/task_fuse.sh



# Install catr
RUN Rscript /cat/scripts/task_install_catr.R
# Run the setup again
# RUN /cat/setupdb.sh

# Label the image
LABEL title="moves-anywhere"
LABEL description="standalone docker-moves image for customized MOVES estimation on any OS. Cloud version."
LABEL version="2.0"
LABEL maintainer="Tim Fraser"
LABEL org.opencontainers.image.authors="tmf77@cornell.edu"

# Specify volumes to be mounted
VOLUME /cat/inputs
VOLUME /cat/scripts
VOLUME /cat/secret

# Set entrypoint so it opens in bash on request
ENTRYPOINT ["/bin/bash"]

# Set the default command to be launch.sh
CMD [ "/bin/bash", "-c", "/cat/scripts/launch.sh" ]
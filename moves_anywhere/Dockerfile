FROM tmf77/docker_moves:v2

# Label the image
LABEL title="moves-anywhere"
LABEL description="standalone docker-moves image for customized MOVES estimation on any OS"
LABEL version="2.0"
LABEL maintainer="Tim Fraser"
LABEL org.opencontainers.image.authors="tmf77@cornell.edu"

# ESTABLISH WORKING DIRECTORY
WORKDIR /cat

# COPY IN MATERIALS
COPY scripts ./scripts

# Make scripts executable
RUN chmod +x /cat/scripts/launch.sh
RUN chmod +x /cat/scripts/launch_runspec.sh

# Install catr
RUN Rscript /cat/scripts/task_install_catr.R
# Run the setup again
RUN /cat/setupdb.sh

# Set entrypoint so it opens in bash on request
ENTRYPOINT ["/bin/bash"]

# Set the default command to be launch.sh
CMD [ "/bin/bash", "-c", "/cat/scripts/launch.sh" ]
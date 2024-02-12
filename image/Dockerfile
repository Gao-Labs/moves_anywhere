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

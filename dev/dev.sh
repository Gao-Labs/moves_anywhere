#' @name dev.sh
#' @author Tim Fraser
#' @description 
#' Script for development of moves_anywhere image, etc.

start docker
main_folder=$(pwd)
# Path to image folder
image_folder="$(pwd)/image_moves"

# Start docker
start docker

# Set working directory
cd "$image_folder";


# Login to dockerhub
docker login

# Set your DockerHub username
DOCKERHUB_USERNAME="tmf77"
# Set your Docker image name and tag
DOCKER_IMAGE_NAME="moves_anywhere"
DOCKER_IMAGE_TAG="v2"
# One time, you'll need to pull this 'starter' image
# docker pull -t tmf77/docker_moves
# Build the Docker image
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG . --no-cache
# Tag the Docker image with the repository name
docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

# Log in to DockerHub
docker login

# Push the Docker image to DockerHub
docker push $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

# Log out from DockerHub (optional)
docker logout

# docker push ghcr.io/gao-labs/moves_anywhere:v0

# docker images 

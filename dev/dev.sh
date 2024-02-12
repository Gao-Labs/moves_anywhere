#' @name dev.sh
#' @author Tim Fraser
#' @description 
#' Script for development of moves_anywhere image, etc.

start docker


docker push ghcr.io/gao-labs/moves_anywhere:v0

docker images 

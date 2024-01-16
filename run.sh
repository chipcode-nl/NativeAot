#!/bin/sh
#
# Run Docker container
#
# Author   : Carl van Heezik
# Revision : 1.0
# Date     : 2023-10-13
export HOST_UID=$(id -u) 
export HOST_GID=$(id -g) 
docker compose run --service-ports container

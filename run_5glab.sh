#!/bin/zsh
#
# This script is an automatization for the steps provided in the srsRAN documentation:
# https://docs.srsran.com/projects/project/en/latest/tutorials/source/srsUE/source/index.html?highlight=ZMQ#id7
# https://open5gs.org/open5gs/docs/guide/02-building-open5gs-from-sources/
#

CYAN='\033[0;36m'
NC='\033[0m'
PROJECT_DIR=$(pwd)

#
# Open5GS
#

# webui 
cd $PROJECT_DIR/projects/open5gs/webui
npm run build   # install dependencies
npm run start   # start webui

#!/bin/zsh
#
# This script is an automatization for the steps provided in the open5gs documentation:
# https://open5gs.org/open5gs/docs/guide/02-building-open5gs-from-sources/
#

CYAN='\033[0;36m'
NC='\033[0m'
PROJECT_DIR=$(pwd)

ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip link set ogstun up

$PROJECT_DIR/projects/open5gs/misc/netconf.sh
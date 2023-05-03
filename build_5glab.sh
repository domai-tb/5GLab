#!/bin/zsh
#
# This script is an automatization for the steps provided in the srsRAN documentation:
# https://docs.srsran.com/projects/project/en/latest/tutorials/source/srsUE/source/index.html?highlight=ZMQ#zeromq-based-setup
#

CYAN='\033[0;36m'
NC='\033[0m'
spin='-\|/'

PROJECT_DIR=$(pwd)
LOG=$PROJECT_DIR/log/build/build_5glab.log
ELOG=$PROJECT_DIR/log/build/build_5glab.error.log
TLOG=$PROJECT_DIR/log/build/build_5glab.test.log

# clean project dir
rm -rf $PROJECT_DIR/projects/*

# clear logs
rm -rf $PROJECT_DIR/log/build/build_5glab.*

# install requirements
echo -e "${CYAN}\nINSTALL REQUEREMENTS:\n${NC}"

# mongodb
apt install -y wget mongodb nodejs
systemctl start mongodb
systemctl enable mongodb

# open5gs dependencies
apt install -y python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev meson cppcheck clang-tidy libtalloc-dev

# srsRAN dependencies
apt install -y cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev libzmq3-dev libboost-all-dev libudev-dev build-essential cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev

# srsGUI dependencies
apt install -y libboost-system-dev libboost-test-dev libboost-thread-dev libqwt-qt5-dev qtbase5-dev

# clone projects
echo -e "${CYAN}\nCLONE REPOSITORIES:\n${NC}"
cd projects
git clone https://github.com/srsran/srsRAN_Project srsRAN_5G
git clone https://github.com/srsran/srsRAN_4G.git
git clone https://github.com/open5gs/open5gs
git clone https://github.com/srsLTE/srsGUI.git

echo -e "${CYAN}\nBUILDING PROJECTS! Check build_5glab.log, build_5glab.test.log and build_5glab.error.log\n${NC}"

# build open5gs
echo "\nINSTALL Open5GS:\n" >> $LOG 2>> $ELOG
$PROJECT_DIR/open5gs_tun.sh >> $LOG 2>> $ELOG
$PROJECT_DIR/projects/open5gs/misc/netconf.sh >> $LOG 2>> $ELOG
cd $PROJECT_DIR/projects/open5gs
meson build --prefix=`pwd`/install >> $LOG 2>> $ELOG
ninja -C build >> $LOG 2>> $ELOG
cd build
ninja install >> $LOG 2>> $ELOG
echo "\n==========================================\n" >> $LOG

# tests
echo "\nTESTING CORRECTNESS OF Open5GS-BUILD\n" &>> $TLOG
meson test -v &>> $TLOG
echo "\n==========================================\n" &>> $TLOG

# webui
$PROJECT_DIR/projects/open5gs/docs/assets/webui/install >> $LOG 2>> $ELOG

# build srsRAN 4G -> prototype 5G UE
#
# Limitations
# The current srsUE implementation has a few feature limitations when running in 5G SA mode. The key feature limitations are as follows:
# 	- Limited to 15 kHz Sub-Carrier Spacing (SCS), which means only FDD bands can be used.
#	- Limited to 10 MHz Bandwidth (BW)
#
echo "\nINSTALL srsRAN 4G:\n" >> $LOG 2>> $ELOG
cd $PROJECT_DIR/projects/srsRAN_4G
mkdir build
cd build
cmake $PROJECT_DIR/projects/srsRAN_4G >> $LOG 2>> $ELOG
make >> $LOG 2>> $ELOG
make install >> $LOG 2>> $ELOG
echo "\n==========================================\n" >> $LOG

# tests
echo "\nTESTING CORRECTNESS OF srsRAN_4G-BUILD\n" &>> $TLOG
make test &>> $TLOG
echo "\n==========================================\n" &>> $TLOG

# build srsRAN 5G (does not include UE)
echo -e "\nINSTALL srsRAN 5G:\n" >> $LOG 2>> $ELOG
cd $PROJECT_DIR/projects/srsRAN_5G
mkdir build
cd build
cmake $PROJECT_DIR/projects/srsRAN_5G -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON >> $LOG 2>> $ELOG
make -j`nproc` >> $LOG 2>> $ELOG
make install >> $LOG 2>> $ELOG
echo "\n==========================================\n" >> $LOG

# tests
echo "\nTESTING CORRECTNESS OF srsRAN_5G-BUILD\n" &>> $TLOG
make test -j $(nproc) &>> $TLOG
echo "\n==========================================\n" &>> $TLOG

# build srsGUI
echo "\nINSTALL srsGUI:\n" >> $LOG 2>> $ELOG
cd $PROJECT_DIR/projects/srsGUI
mkdir build
cd build
cmake $PROJECT_DIR/projects/srsGUI >> $LOG 2>> $ELOG
make >> $LOG 2>> $ELOG
echo "\n==========================================\n" >> $LOG
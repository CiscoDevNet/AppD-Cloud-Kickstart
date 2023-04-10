#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install neofetch, a command-line system information tool written in bash 3.2+.
#
# Neofetch displays information about your operating system, software and hardware in an aesthetic
# and visually pleasing way. The overall purpose of Neofetch is to be used in screen-shots of your
# system. Neofetch shows the information other people want to see.
#
# The information by default is displayed alongside your operating system's logo. You can further
# configure Neofetch to instead use an image, a custom ASCII file, your wallpaper or exactly what
# you want it to. Through the use of command-line flags and the configuration file you can change
# existing information outputs or add your own custom ones.
#
# For more details, please visit:
#   https://github.com/dylanaraps/neofetch
#   https://github.com/dylanaraps/neofetch/wiki/Installation
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# prepare yum packages. ----------------------------------------------------------------------------
# install packages needed to install neofetch from source.
yum -y install gcc make ncurses ncurses-devel

# install neofetch binaries from source. -----------------------------------------------------------
neofetch_home="neofetch"
neofetch_release="7.1.0"
neofetch_folder="neofetch-${neofetch_release}"
neofetch_binary="${neofetch_release}.tar.gz"

# create neofetch source parent folder.
mkdir -p /usr/local/src/${neofetch_home}
cd /usr/local/src/${neofetch_home}

# download neofetch source from github.com.
curl --silent --location https://github.com/dylanaraps/neofetch/archive/refs/tags/${neofetch_binary} --output ${neofetch_binary}

# extract neofetch source.
rm -Rf ${neofetch_folder}
tar -zxvf ${neofetch_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${neofetch_folder}
rm -f ${neofetch_binary}

# build and install neofetch binary.
cd ${neofetch_folder}
make PREFIX=/usr/local install

# set neofetch home environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
neofetch --version
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# display system information. ----------------------------------------------------------------------
neofetch

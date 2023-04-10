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

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install neofetch. --------------------------------------------------------------------------------
apt-get -y install neofetch

# set neofetch home environment variables.
PATH=/usr/local/bin:/usr/bin:$PATH
export PATH

# verify installation.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
neofetch --version

# display system information. ----------------------------------------------------------------------
neofetch
set -e  # turn 'exit pipeline on non-zero return status' back ON.

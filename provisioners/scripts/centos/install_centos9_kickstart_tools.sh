#!/bin/sh -eux
# install useful command-line developer tools on centos 9.

# install epel repository. -------------------------------------------------------------------------
dnf -y install epel-release
dnf repolist

# install neofetch system information tool. ---------------------------------------------------------
dnf -y install neofetch

# verify installation.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
neofetch --version
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# display system information.
neofetch

# install git. -------------------------------------------------------------------------------------
dnf -y install git
git --version

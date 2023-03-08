#!/bin/sh -eux
# install useful command-line developer tools on centos 9.

# install epel repository. -------------------------------------------------------------------------
dnf -y install epel-release
dnf repolist

# install git. -------------------------------------------------------------------------------------
dnf -y install git
git --version

#!/bin/sh -eux
# install useful command-line developer tools on ubuntu linux.

# install python 2.x, pip, and setuptools. ---------------------------------------------------------
apt -y install python2
python2 --version

# install pip3 and setuptools. ---------------------------------------------------------------------
apt -y install python3-pip
pip3 --version

# install python 2.x setup tools.
apt -y install python-setuptools
#pip install --upgrade setuptools
#easy_install --version

# install additional developer tools. --------------------------------------------------------------
apt -y install curl git tree wget unzip man

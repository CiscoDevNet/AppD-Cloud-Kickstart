#!/bin/sh -eux
# install python3 and pip3 on amazon linux 2.

# install python 3.x and tools. --------------------------------------------------------------------
yum -y install python3 python3-pip python3-setuptools python3-wheel
python3 --version
pip3 --version

# update 'root' path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# upgrade python 3.x pip and setup tools.
pip3 install --upgrade pip
pip3 install --upgrade setuptools

# verify installation.
pip --version
pip3 --version
easy_install --version

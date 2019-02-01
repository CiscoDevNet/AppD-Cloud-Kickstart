#!/bin/sh -eux
# install useful command-line developer tools on amazon linux 2.

# install python 2.x pip and setuptools. -----------------------------------------------------------
yum -y install python2-pip
python --version
pip --version

# upgrade python 2.x pip.
pip install --upgrade pip
pip --version

# install python 2.x setup tools.
yum -y install python2-setuptools
pip install --upgrade setuptools
easy_install --version

# install tree. ------------------------------------------------------------------------------------
yum -y install tree
tree --version

# install git. -------------------------------------------------------------------------------------
yum -y install git
git --version

# install vim. -------------------------------------------------------------------------------------
amazon-linux-extras install -y vim
vim --version | awk 'FNR < 3 {print $0}'

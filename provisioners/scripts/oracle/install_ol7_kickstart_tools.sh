#!/bin/sh -eux
# install useful command-line developer tools on oracle linux 7.

# install epel repository. -------------------------------------------------------------------------
yum -y install oracle-epel-release-el7
yum-config-manager --enable ol7_developer_EPEL

# install python 2.x pip and setuptools. -----------------------------------------------------------
yum -y install python2-pip
python --version
pip --version

# upgrade python 2.x pip.
#python -m pip install --upgrade pip
#pip --version

# install python 2.x setup tools.
yum -y install python-setuptools
#python -m pip install --upgrade setuptools
#pip install --upgrade setuptools
#easy_install --version

# install software collections library repository. (needed later for python 3.x.) ------------------
yum -y install oracle-softwarecollection-release-el7
yum-config-manager --enable ol7_software_collections

# install software collections library. (needed later for python 3.x.) -----------------------------
yum -y install scl-utils

# install git. -------------------------------------------------------------------------------------
yum -y install git
git --version

#!/bin/sh -eux
# install useful command-line developer tools on centos 7.

# install epel repository if needed. ---------------------------------------------------------------
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then
  rm -f /tmp/epel-release-7-14.noarch.rpm
# rm -f /tmp/epel-release-latest-7.noarch.rpm
  curl --silent --location https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm --output /tmp/epel-release-7-14.noarch.rpm
# curl --silent --location https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --output /tmp/epel-release-latest-7.noarch.rpm
  yum -y install /tmp/epel-release-7-14.noarch.rpm
# yum -y install /tmp/epel-release-latest-7.noarch.rpm
fi

# install python 2.x pip and setuptools. -----------------------------------------------------------
yum -y install python-pip
python --version
pip --version

# upgrade python 2.x pip.
#pip install --upgrade pip
#pip --version

# install python 2.x setup tools.
yum -y install python-setuptools
#pip install --upgrade setuptools
#easy_install --version

# install software collections library. (needed later for python 3.x.) -----------------------------
yum -y install scl-utils
yum -y install centos-release-scl

# centos linux 7 reached eol on July 1, 2024, so 'mirrorlist.centos.org' no longer exists.
# in order to install packages, you have to adjust repositories from 'mirrorlist' to 'baseurl'.
# for most cases 'vault.centos.org' will work well.
sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

# install git. -------------------------------------------------------------------------------------
yum -y install git
git --version

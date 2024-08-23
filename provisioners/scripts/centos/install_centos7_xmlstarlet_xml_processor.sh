#!/bin/sh -eux
# install xmlstarlet command-line xml processor for linux 64-bit.

# install epel repository if needed. ---------------------------------------------------------------
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then
  rm -f /tmp/epel-release-7-14.noarch.rpm
# rm -f epel-release-latest-7.noarch.rpm
  curl --silent --location https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm --output /tmp/epel-release-7-14.noarch.rpm
# wget --no-verbose https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum -y install /tmp/epel-release-7-14.noarch.rpm
# yum -y install epel-release-latest-7.noarch.rpm
fi

# install xmlstarlet xml processor. ----------------------------------------------------------------
yum -y install xmlstarlet

# verify installation.
xmlstarlet --version

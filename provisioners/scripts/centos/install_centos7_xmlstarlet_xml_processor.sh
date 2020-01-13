#!/bin/sh -eux
# install xmlstarlet command-line xml processor for linux 64-bit.

# install epel repository if needed. ---------------------------------------------------------------
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then
  rm -f install epel-release-latest-7.noarch.rpm
  wget --no-verbose https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum -y install epel-release-latest-7.noarch.rpm
fi

# install xmlstarlet xml processor. ----------------------------------------------------------------
yum -y install xmlstarlet

# verify installation.
xmlstarlet --version

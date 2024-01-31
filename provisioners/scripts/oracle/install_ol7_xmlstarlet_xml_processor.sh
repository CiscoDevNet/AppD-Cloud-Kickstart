#!/bin/sh -eux
# install xmlstarlet command-line xml processor for oracle linux 64-bit.

# install epel repository. -------------------------------------------------------------------------
yum -y install oracle-epel-release-el7
yum-config-manager --enable ol7_developer_EPEL

# install xmlstarlet xml processor. ----------------------------------------------------------------
yum -y install xmlstarlet

# verify installation.
xmlstarlet --version

#!/bin/sh -eux
# install xmlstarlet command-line xml processor for oracle linux 8 64-bit.

# install epel repository. -------------------------------------------------------------------------
dnf -y install oracle-epel-release-el8
dnf -y install oraclelinux-developer-release-el8

dnf config-manager --set-enabled ol8_developer_EPEL
dnf config-manager --set-enabled ol8_developer

# install xmlstarlet xml processor. ----------------------------------------------------------------
dnf -y install xmlstarlet

# verify installation.
xmlstarlet --version

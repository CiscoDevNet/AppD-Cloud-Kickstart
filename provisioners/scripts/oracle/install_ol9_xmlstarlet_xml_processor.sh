#!/bin/sh -eux
# install xmlstarlet command-line xml processor for oracle linux 9 64-bit.

# install epel repository. -------------------------------------------------------------------------
dnf -y install oracle-epel-release-el9
dnf -y install oraclelinux-developer-release-el9

dnf config-manager --set-enabled ol9_developer_EPEL
dnf config-manager --set-enabled ol9_developer

# install xmlstarlet xml processor. ----------------------------------------------------------------
dnf -y install xmlstarlet

# verify installation.
xmlstarlet --version

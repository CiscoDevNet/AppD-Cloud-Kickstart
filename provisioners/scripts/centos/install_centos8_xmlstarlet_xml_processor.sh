#!/bin/sh -eux
# install xmlstarlet command-line xml processor for linux 64-bit.

# install epel repository (if needed). -------------------------------------------------------------
dnf -y install epel-release

# install xmlstarlet xml processor. ----------------------------------------------------------------
dnf -y install xmlstarlet

# verify installation.
xmlstarlet --version

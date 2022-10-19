#!/bin/sh -eux
# install xmlstarlet command-line xml processor for ubuntu linux 64-bit.

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install xmlstarlet xml processor. ----------------------------------------------------------------
apt-get -y install xmlstarlet

# verify installation.
xmlstarlet --version

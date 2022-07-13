#!/bin/sh -eux
# install xmlstarlet command-line xml processor for ubuntu linux 64-bit.

# install xmlstarlet xml processor. ----------------------------------------------------------------
apt -y install xmlstarlet

# verify installation.
xmlstarlet --version

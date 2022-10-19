#!/bin/sh -eux
# install ansible on ubuntu linux.

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install ansible. ---------------------------------------------------------------------------------
apt-get -y install ansible

# verify ansible installation.
ansible --version

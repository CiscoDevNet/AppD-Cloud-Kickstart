#!/bin/sh -eux
# install ansible on ubuntu linux.

# install ansible. ---------------------------------------------------------------------------------
apt -y install ansible

# verify ansible installation.
ansible --version

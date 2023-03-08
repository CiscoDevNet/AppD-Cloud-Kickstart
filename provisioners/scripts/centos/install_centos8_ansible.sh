#!/bin/sh -eux
# install ansible on centos linux 8.x.

# install ansible. ---------------------------------------------------------------------------------
dnf -y install ansible

# verify ansible installation.
ansible --version

#!/bin/sh -eux
# install ansible on amazon linux 2.

# install ansible. -------------------------------------------------------------
amazon-linux-extras install -y ansible2

# verify ansible installation.
ansible --version

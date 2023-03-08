#!/bin/sh -eux
# install podman compose on centos 8.x.
#
# 'podman-compose' is an implementation of 'docker-compose' with a Podman backend.
# The main objective of this project is to be able to run docker-compose.yml files unmodified
# and rootless.

# install podman-compose utility. ------------------------------------------------------------------
dnf -y install podman-compose

# verify installation.
podman-compose --version

#!/bin/sh -eux
# install the podman container tools on fedora linux (cloud edition).
#
# The Container Tools encompass software packages required to build and run Linux Containers on
# RHEL-based Linux operating systems. The primary piece of software core to this set is Podman,
# but there are many other pieces of software including, but not limited to Buildah and Skopeo.
#
# https://access.redhat.com/support/policy/updates/containertools

# install podman container tools. ------------------------------------------------------------------
dnf -y install buildah skopeo podman

# install docker-like syntax for the 'podman' command.
dnf -y install podman-docker

# display configuration info and verify version. ---------------------------------------------------
podman info
podman version
podman --version

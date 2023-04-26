#!/bin/sh -eux
# update the centos linux 8 repositories.

# install useful base utilities. -------------------------------------------------------------------
dnf -y install dnf-utils dnf-plugins-core dnf-plugin-versionlock bind-utils unzip vim-enhanced tree bc
dnf -y install openssh-clients sudo kernel-headers kernel-devel gcc make perl selinux-policy-devel wget nfs-utils net-tools bzip2
dnf -y install bash-completion

# install the latest os updates. -------------------------------------------------------------------
dnf -y update

# remove package kit utility to turn-off auto-update of packages. ----------------------------------
dnf -y remove PackageKit

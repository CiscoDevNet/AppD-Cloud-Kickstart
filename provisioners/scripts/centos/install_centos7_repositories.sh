#!/bin/sh -eux
# update the centos linux 7 repositories.

# install useful base utilities. -------------------------------------------------------------------
yum -y install yum-utils yum-plugin-versionlock bind-utils unzip vim-enhanced tree bc
yum -y install openssh-clients sudo kernel-headers kernel-devel gcc make perl selinux-policy-devel wget nfs-utils net-tools bzip2
yum -y install bash-completion bash-completion-extras

# install the latest ol7 updates. ------------------------------------------------------------------
yum -y update

# remove package kit utility to turn-off auto-update of packages. ----------------------------------
yum -y remove PackageKit


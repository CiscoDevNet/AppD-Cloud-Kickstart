#!/bin/sh -eux
# update the centos linux 8 repositories.

# centos linux 8 will reach eol in 2024, so 'mirrorlist.centos.org' no longer exists.
# in order to install packages, you have to adjust repositories from 'mirrorlist' to 'baseurl'.
# for most cases 'vault.centos.org' will work well.
sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

# install useful base utilities. -------------------------------------------------------------------
dnf -y install dnf-utils dnf-plugins-core dnf-plugin-versionlock bind-utils unzip vim-enhanced tree bc
dnf -y install openssh-clients sudo kernel-headers kernel-devel gcc make perl selinux-policy-devel wget nfs-utils net-tools bzip2
dnf -y install bash-completion

# install the latest os updates. -------------------------------------------------------------------
dnf -y update

# remove package kit utility to turn-off auto-update of packages. ----------------------------------
dnf -y remove PackageKit

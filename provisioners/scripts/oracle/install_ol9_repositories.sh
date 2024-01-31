#!/bin/sh -eux
# update the oracle linux 9 repositories.

# install epel repository. -------------------------------------------------------------------------
dnf -y install oracle-epel-release-el9
dnf -y install oraclelinux-developer-release-el9

dnf config-manager --set-enabled ol9_developer_EPEL
dnf config-manager --set-enabled ol9_developer

# install useful base utilities. -------------------------------------------------------------------
dnf -y install yum-utils yum-plugin-versionlock bind-utils unzip vim-enhanced tree bc
dnf -y install openssh-clients sudo kernel-headers kernel-devel gcc make perl selinux-policy-devel wget nfs-utils net-tools bzip2
dnf -y install bash-completion

# install the latest os updates. -------------------------------------------------------------------
dnf -y upgrade

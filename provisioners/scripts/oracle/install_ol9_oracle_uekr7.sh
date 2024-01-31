#!/bin/sh -eux
# install the oracle linux 9 uekr7 kernel.

# ensure that the uekr7 kernel is enabled by default. ----------------------------------------------
dnf config-manager --set-enabled ol9_UEKR7
dnf config-manager --set-enabled ol9_addons

dnf -y install oracle-epel-release-el9
dnf -y install oraclelinux-developer-release-el9

dnf config-manager --set-enabled ol9_developer_EPEL
dnf config-manager --set-enabled ol9_developer

# install the latest ol9 updates. ------------------------------------------------------------------
dnf -y upgrade

# install kernel development tools and headers for building guest additions. -----------------------
dnf -y install kernel-uek-devel
dnf -y install kernel-uek

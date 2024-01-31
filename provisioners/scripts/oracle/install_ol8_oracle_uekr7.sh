#!/bin/sh -eux
# install the oracle linux 8 uekr7 kernel.

# ensure that the uekr7 kernel is enabled by default. ----------------------------------------------
dnf config-manager --set-enabled ol8_UEKR7
dnf config-manager --set-enabled ol8_addons
dnf config-manager --set-disabled ol8_UEKR6

dnf -y install oracle-epel-release-el8
dnf -y install oraclelinux-developer-release-el8

dnf config-manager --set-enabled ol8_developer_EPEL
dnf config-manager --set-enabled ol8_developer

# install the latest ol8 updates. ------------------------------------------------------------------
dnf -y upgrade

# install kernel development tools and headers for building guest additions. -----------------------
dnf -y install kernel-uek-devel
dnf -y install kernel-uek

#!/bin/sh -eux
# install the oracle linux 7 uekr6 kernel.

# ensure that the uekr6 kernel is enabled by default. ----------------------------------------------
yum-config-manager --enable ol7_UEKR6
yum-config-manager --disable ol7_UEKR5
yum-config-manager --disable ol7_UEKR4
yum-config-manager --disable ol7_UEKR3
yum-config-manager --enable ol7_addons
yum-config-manager --enable ol7_developer_EPEL
yum-config-manager --enable ol7_software_collections
yum-config-manager --enable ol7_optional_latest

# install the latest ol7 updates. ------------------------------------------------------------------
yum -y update

# install kernel development tools and headers for building guest additions. -----------------------
yum -y install kernel-uek-devel
yum -y install kernel-uek

# remove package kit utility to turn-off auto-update of packages. ----------------------------------
yum -y remove PackageKit

# update the yum configuration. --------------------------------------------------------------------
/usr/bin/ol_yum_configure.sh

# re-enable the correct repositories after the yum configuration update. ---------------------------
yum-config-manager --enable ol7_UEKR6
yum-config-manager --disable ol7_UEKR5
yum-config-manager --disable ol7_UEKR4
yum-config-manager --disable ol7_UEKR3
yum-config-manager --enable ol7_addons
yum-config-manager --enable ol7_developer_EPEL
yum-config-manager --enable ol7_software_collections
yum-config-manager --enable ol7_optional_latest

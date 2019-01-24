#!/bin/sh -eux
# update the centos linux 7 repositories.

# install the latest ol7 updates. ----------------------------------------------
yum -y update

# remove package kit utility to turn-off auto-update of packages. --------------
yum -y remove PackageKit

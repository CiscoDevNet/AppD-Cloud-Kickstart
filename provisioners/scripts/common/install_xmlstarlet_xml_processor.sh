#!/bin/sh -eux
# install xmlstarlet command-line xml processor for linux 64-bit.

# install tools needed to build xmlstarlet from source. --------------------------------------------
dnf -y install libxml2-devel libxslt-devel

# install xmlstarlet binaries from source. ---------------------------------------------------------
xmlstarlet_home="xmlstarlet"
xmlstarlet_release="1.6.1"
xmlstarlet_folder="${xmlstarlet_home}-${xmlstarlet_release}"
xmlstarlet_binary="${xmlstarlet_folder}.tar.gz"

# create xmlstarlet source parent folder.
mkdir -p /usr/local/src/${xmlstarlet_home}
cd /usr/local/src/${xmlstarlet_home}

# download xmlstarlet source from sourceforge.net.
rm -f ${xmlstarlet_binary}
curl --silent --location https://sourceforge.net/projects/xmlstar/files/xmlstarlet/${xmlstarlet_release}/${xmlstarlet_binary}/download --output ${xmlstarlet_binary}

# extract xmlstarlet source.
rm -Rf ${xmlstarlet_folder}
tar -zxvf ${xmlstarlet_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${xmlstarlet_folder}
rm -f ${xmlstarlet_binary}

# build and install xmlstarlet binaries.
cd ${xmlstarlet_folder}

./configure --with-libxml-include-prefix=/usr/include/libxml2 --program-suffix=starlet
make
make install

# verify installation. -----------------------------------------------------------------------------
# set xmlstarlet environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify xmlstarlet version.
xmlstarlet --version

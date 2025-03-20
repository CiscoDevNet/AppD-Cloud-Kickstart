#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Curl command-line tool on RHEL-based Linux 7.x distros.
#
# Curl is a command-line tool for transferring data specified with URL syntax. Learn how to use
# curl by reading the manpage or everything curl.
#
# For more details, please visit:
#   https://github.com/curl/curl?tab=readme-ov-file
#   https://curl.se/docs/manpage.html
#   https://everything.curl.dev/
#   https://gist.github.com/thesuhu/bccd43a4dc998e738d1f3578f34949ce
#   https://curl.se/download/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install tools needed to build curl from source. --------------------------------------------------
yum -y install wget gcc openssl-devel make

# install curl binaries from source. ---------------------------------------------------------------
curl_home="curl"
curl_release="7.88.1"
curl_folder="curl-${curl_release}"
curl_binary="${curl_folder}.tar.gz"

# create curl source parent folder.
mkdir -p /usr/local/src/curl
cd /usr/local/src/curl

# download curl source from curl.se.
wget --no-verbose https://curl.se/download/${curl_binary}

# extract curl source.
rm -Rf ${curl_folder}
tar -zxvf ${curl_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${curl_folder}
rm -f ${curl_binary}

# build and install curl binaries.
cd ${curl_folder}
./configure --prefix=/usr/local --with-ssl
make
make install
ldconfig

# set path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation. -----------------------------------------------------------------------------
curl --version

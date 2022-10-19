#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install PhantomJS headless browser on Ubuntu Linux 64-bit.
#
# PhantomJS is a headless WebKit scriptable with JavaScript.
#
# For more details, please visit:
#   https://phantomjs.org/
#   https://phantomjs.org/api/
#   https://phantomjs.org/quick-start.html
#   https://github.com/ariya/phantomjs
#
# NOTE: All inputs are defined by external environment variables.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set phantomjs install parameters. ----------------------------------------------------------------
phantomjs_release="2.1.1"
phantomjs_home="phantomjs-${phantomjs_release}"
phantomjs_folder="phantomjs-${phantomjs_release}-linux-x86_64"
phantomjs_binary="phantomjs-${phantomjs_release}-linux-x86_64.tar.bz2"
phantomjs_sha256="86dd9a4bf4aee45f1a84c9f61cf1947c1d6dce9b9e8d2a907105da7852460d2f"

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install phantomjs gui runtime with dependencies. -------------------------------------------------
apt-get -y install fontconfig fontconfig-config
apt-get -y install build-essential chrpath libssl-dev libxft-dev 
apt-get -y install libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev 

# install phantomjs headless browser. --------------------------------------------------------------
# create phantom parent folder.
mkdir -p /usr/local/share
cd /usr/local/share

# download phantomjs binary from bitbucket.org.
rm -f ${phantomjs_binary}
wget --no-verbose https://bitbucket.org/ariya/phantomjs/downloads/${phantomjs_binary}

# verify the downloaded binary.
echo "${phantomjs_sha256} ${phantomjs_binary}" | sha256sum --check
# ${phantomjs_folder}.tar.bz2: OK

# extract phantomjs binary.
rm -f ${phantomjs_home}
tar -jxvf ${phantomjs_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${phantomjs_folder}
ln -s ${phantomjs_folder} ${phantomjs_home}
rm -f ${phantomjs_binary}

# create link to binary in '/usr/local/bin'.
mkdir -p /usr/local/bin
cd /usr/local/bin
ln -sf ../share/${phantomjs_home}/bin/phantomjs phantomjs

# set path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# if ubuntu release is '22.04', apply fix for incompatible openssl.
ubuntu_release=$(lsb_release -rs)
if [ "$ubuntu_release" == "22.04" ]; then
  OPENSSL_CONF=/dev/null
  export OPENSSL_CONF
fi

# verify installation.
phantomjs --version

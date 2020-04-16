#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install PhantomJS headless browser.
#
# PhantomJS is a headless WebKit scriptable with JavaScript.
#
# For more details, please visit:
#   https://phantomjs.org/
#   https://phantomjs.org/api/
#   https://github.com/ariya/phantomjs
#
# NOTE: All inputs are defined by external environment variables.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install tools needed for phantomjs runtime. ------------------------------------------------------
yum -y install glibc fontconfig freetype freetype-devel fontconfig-devel wget bzip2

# install phantomjs headless browser. --------------------------------------------------------------
# create phantom parent folder.
mkdir -p /usr/local/share
cd /usr/local/share

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-phantomjs.${curdate}.out https://github.com/ariya/phantomjs/releases/latest --output /dev/null
phantomjs_release=$(awk '{ sub("\r$", ""); print }' curl-phantomjs.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
phantomjs_release="2.1.1"
phantomjs_folder="phantomjs-${phantomjs_release}-linux-x86_64"
phantomjs_binary="phantomjs-${phantomjs_release}-linux-x86_64.tar.bz2"
rm -f curl-phantomjs.${curdate}.out

# download jq binary from github.com.
rm -f ${phantomjs_binary}
wget --no-verbose https://bitbucket.org/ariya/phantomjs/downloads/${phantomjs_binary}

# extract phantomjs binary.
tar -jxvf ${phantomjs_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${phantomjs_folder}
chmod 755 ${phantomjs_folder}/bin/phantomjs
rm -f ${phantomjs_binary}

# create link to binary in '/usr/local/bin'.
mkdir -p /usr/local/bin
cd /usr/local/bin
ln -sf ../share/${phantomjs_folder}/bin/phantomjs phantomjs

# set path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
phantomjs --version

#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install PhantomJS headless browser on CentOS Linux 64-bit.
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

# install tools needed for phantomjs runtime. ------------------------------------------------------
yum -y install glibc fontconfig freetype freetype-devel fontconfig-devel wget bzip2

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

# verify phantomjs installation. -------------------------------------------------------------------
# set path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# set phantomjs environment variables (if needed).
user_host_os=$(hostnamectl | awk '/Operating System/ {printf "%s %s %s %s %s", $3, $4, $5, $6, $7}' | xargs)

# if os release is 'amazon linux 2023', apply fix for incompatible openssl.
if [ "${user_host_os:0:17}" = "Amazon Linux 2023" ]; then
  OPENSSL_CONF=/dev/null
  export OPENSSL_CONF
fi

# verify installation.
phantomjs --version

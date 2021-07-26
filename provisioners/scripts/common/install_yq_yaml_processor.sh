#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install yq command-line YAML processor for linux 64-bit.
#
# yq is a lightweight and portable command-line YAML processor. yq uses jq like syntax but works
# with yaml files as well as json. It doesn't yet support everything jq does--but it does support
# the most common operations and functions, and more is being added continuously.
#
# Usage examples are located at the end of this file.
#
# For more details, please visit:
#   https://mikefarah.gitbook.io/yq/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install yq yaml processor. -----------------------------------------------------------------------
yq_release="v4.11.2"
yq_exe="yq_linux_amd64"
yq_binary="${yq_exe}.tar.gz"
yq_sha256="6b891fd5bb13820b2f6c1027b613220a690ce0ef4fc2b6c76ec5f643d5535e61"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download yq binary from github.com.
rm -f ${yq_binary}
curl --silent --location "https://github.com/mikefarah/yq/releases/download/${yq_release}/${yq_binary}" --output ${yq_binary}

# extract yq executable.
rm -f ${yq_exe}
tar -zxvf ${yq_binary} --no-same-owner --no-overwrite-dir
chown root:root ./${yq_exe}
rm -f ${yq_binary}

# verify the downloaded executable.
echo "${yq_sha256} ${yq_exe}" | sha256sum --check
# ${yq_exe}: OK

# rename executable and change execute permissions.
mv -f ${yq_exe} yq
chmod 755 yq

# set yq environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
yq --version

# yq command-line examples. ------------------------------------------------------------------------
# Example #1:
#   Easy YAML formatter.
#
#   $ yq eval --prettyPrint sample.yaml 
#   $ cat sample.yml | yq eval --prettyPrint
#
# Example #2:
#   Runs the expression against each file in series.
#
#   $ yq eval '.a.b | length' f1.yml f2.yml 
#
# Example #3:
#   Read from STDIN with '-'.
#
#   $ cat file.yml | yq eval '.a.b' f1.yml -  f2.yml
#
# Example #4:
#   Prints a new YAML document.
#
#   $ yq eval --null-input '.a.b.c = "cat"' 
#
# Example #5:
#   Updates file.yaml directly.
#
#   $ yq eval '.a.b = "cool"' -i file.yaml 

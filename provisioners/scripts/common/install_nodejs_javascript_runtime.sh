#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Node.js JavaScript runtime and supporting tools (npm and nvm).
#
# Node.js is an asynchronous event-driven JavaScript runtime designed to build scalable network
# applications.
#
# npm (originally short for Node Package Manager) is a package manager for JavaScript and is the
# default package manager for the Node.js JavaScript runtime environment. It consists of a
# command-line client, also called npm, and an online package database called the npm registry.
#
# nvm (Node Version Manager) is a POSIX-compliant bash script to manage multiple active Node.js
# versions.
#
# For more details, please visit:
#   https://nodejs.org/en/
#   https://www.npmjs.com/
#   https://github.com/nvm-sh/nvm/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] node.js nvm install parameters [w/ defaults].
user_name="${user_name:-centos}"

# install nvm (node version mannager). -------------------------------------------------------------
nvm_binary="nvm-linux-amd64"

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-nvm.${curdate}.out https://github.com/nvm-sh/nvm/releases/latest --output /dev/null
nvm_release=$(awk '{ sub("\r$", ""); print }' curl-nvm.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
nvm_release="v0.37.2"
rm -f curl-nvm.${curdate}.out

# install nvm.
runuser -c "curl --silent --location https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_release}/install.sh | bash" - ${user_name}

# verify installation.
runuser -c "nvm --version" - ${user_name}

# install node.js javascript runtime. --------------------------------------------------------------
# install current node.js lts (long term support) version.
runuser -c "nvm install --lts" - ${user_name}

# verify node installation.
runuser -c "node --version" - ${user_name}
runuser -c "npm --version" - ${user_name}

# upgrade npm (node package manager) to latest version. --------------------------------------------
runuser -c "npm install -g npm@latest" - ${user_name}

# verify npm installation.
runuser -c "npm --version" - ${user_name}

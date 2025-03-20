#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Serverless Framework Command Line Interface (CLI) by Serverless, Inc.
#
# The Serverless Framework helps you build serverless apps with radically less overhead and cost.
# It provides a powerful, unified experience to develop, deploy, test, secure and monitor your
# serverless applications.
#
# The Serverless Framework consists of an open source CLI that makes it easy to develop, deploy
# and test serverless apps across different cloud providers, as well as a hosted Dashboard that
# includes features designed to further simplify serverless development, deployment, and testing,
# and enable you to easily secure and monitor your serverless apps.
#
# For more details, please visit:
#   https://serverless.com/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       This script requires the 'npm' (node package manager) cli for installation.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] node.js nvm install parameters [w/ defaults].
user_name="${user_name:-centos}"
serverless_release="${serverless_release:-3.38.0}"

# check if 'npm' is configured. --------------------------------------------------------------------
#if [ ! -f "/home/${user_name}/.nvm" ]; then
#  set +x  # temporarily turn command display OFF.
#  echo "Error: 'npm' cli not found."
#  echo "NOTE: This script requires the 'npm' (node package manager) cli for installation."
#  echo "      For more information, visit: https://www.npmjs.com/"
#  set -x  # turn command display back ON.
#  exit 1
#fi

# install serverless framework cli. ----------------------------------------------------------------
runuser -c "npm install -g serverless@${serverless_release}" - ${user_name}
#runuser -c "npm install -g serverless@latest" - ${user_name}

# verify serverless installation.
runuser -c "serverless --version" - ${user_name}

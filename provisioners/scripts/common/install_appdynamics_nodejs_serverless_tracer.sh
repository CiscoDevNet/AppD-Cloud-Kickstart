#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Node.js Serverless Tracer by AppDynamics.
#
# Serverless Application Performance Monitoring (Serverless APM) for AWS Lambda gives you
# end-to-end visibility into the performance of your application's components that run as
# functions on serverless compute environments. Serverless APM correlates business transactions
# between AWS Lambda functions and:
#
#   * Components instrumented with AppDynamics app agents
#   * Devices instrumented with AppDynamics End User Monitoring (EUM) agents 
#   * AWS Lambda function that invokes another function.
#
# The Node.js Serverless Tracer is packaged in the form of a tracer library and can be obtained
# using the npm registry. The tracer provides Serverless APM for AWS Lambda functionality for AWS
# functions implemented in JavaScript and requires:
#
#   * A subscription to Serverless APM for AWS Lambda through AWS Marketplace. 
#   * A SaaS Controller version 4.5.11, and later
#   * An AWS Lambda function implemented with Node.js versions 8 and later
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/latest/Serverless+APM+for+AWS+Lambda
#   https://docs.appdynamics.com/display/latest/Node.js+Serverless+Tracer
#   https://docs.appdynamics.com/display/latest/Node.js+Serverless+Tracer+Notes
#   https://www.npmjs.com/package/appdynamics-lambda-tracer
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       This script requires the 'npm' (node package manager) cli for installation.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] node.js nvm install parameters [w/ defaults].
user_name="${user_name:-centos}"

# check if 'npm' is configured. --------------------------------------------------------------------
#if [ ! -f "/home/${user_name}/.nvm" ]; then
#  echo "Error: 'npm' cli not found."
#  echo "NOTE: This script requires the 'npm' (node package manager) cli for installation."
#  echo "      For more information, visit: https://www.npmjs.com/"
#  exit 1
#fi

# install nodejs serverless tracer. ----------------------------------------------------------------
runuser -c "npm install -g appdynamics-lambda-tracer@latest" - ${user_name}

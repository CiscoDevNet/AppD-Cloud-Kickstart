#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Azure Command Line Interface (CLI) by Microsoft on Ubuntu Linux.
#
# The Azure command-line interface (Azure CLI) is a set of commands used to create and manage
# Azure resources. The Azure CLI is available across Azure services and is designed to get you
# working quickly with Azure, with an emphasis on automation.
#
# For more details, please visit:
#   https://docs.microsoft.com/en-us/cli/azure/
#   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# prepare the azure-cli repository for installation. -----------------------------------------------
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# verify installation.
# set azure cli environment variables.
PATH=/usr/bin:$PATH
export PATH

# verify azure cli version.
az --version

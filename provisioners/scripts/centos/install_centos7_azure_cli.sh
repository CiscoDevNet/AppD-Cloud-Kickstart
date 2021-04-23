#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Azure Command Line Interface (CLI) by Microsoft.
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
# import the microsoft repository key.
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# create the azure-cli repository.
cat <<EOF > /etc/yum.repos.d/azure-cli.repo
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# install the azure-cli. ---------------------------------------------------------------------------
yum -y install azure-cli

# verify installation.
# set azure cli environment variables.
PATH=/usr/bin:$PATH
export PATH

# verify azure cli version.
az --version

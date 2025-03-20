#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Vault Tool for Managing Secrets by HashiCorp.
#
# Secure, store and tightly control access to tokens, passwords, certificates, encryption keys
# for protecting secrets and other sensitive data using a UI, CLI, or HTTP API.
#
# The key use cases for Vault are:
#
# - Secrets Management: Centrally store, access, and deploy secrets across applications,
#   systems, and infrastructure.
# - Data Encryption: Keep application data secure with one centralized workflow to encrypt
#   data in flight and at rest.
# - Identity-based Access: Authenticate and access different clouds, systems, and endpoints
#   using trusted identities.
#
# For more details, please visit:
#   https://vaultproject.io/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install hashicorp vault. -------------------------------------------------------------------------
vault_release="1.19.0"

# set the vault tool binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  vault_binary="vault_${vault_release}_linux_amd64.zip"
  vault_sha256="9df904271319452bbb37825cfe50726383037550cc04b7c2d0ab09e2f08f82a1"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  vault_binary="vault_${vault_release}_linux_arm64.zip"
  vault_sha256="252bf12d0ce1824860d6e06bd21b74b548eedd6a35225f12bf38482a4c78bef6"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download vault binary from hashicorp.com.
rm -f ${vault_binary}
wget --no-verbose https://releases.hashicorp.com/vault/${vault_release}/${vault_binary}

# verify the downloaded binary.
echo "${vault_sha256} ${vault_binary}" | sha256sum --check
# vault_${vault_release}_linux_amd64.zip: OK
# vault_${vault_release}_linux_arm64.zip: OK

# extract vault binary.
rm -f vault LICENSE.txt
unzip ${vault_binary} vault
chmod 755 vault
rm -f ${vault_binary}

# verify installation. -----------------------------------------------------------------------------
# set vault environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify vault version.
vault version

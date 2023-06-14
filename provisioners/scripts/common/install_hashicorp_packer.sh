#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Packer Machine and Container Image Tool by HashiCorp.
#
# Packer is an open source tool for creating identical machine images for multiple platforms from
# a single source configuration. Packer is lightweight, runs on every major operating system, and
# is highly performant, creating machine images for multiple platforms in parallel. Packer does
# not replace configuration management like Chef or Puppet. In fact, when building images, Packer
# is able to use tools like Chef or Puppet to install software onto the image.
#
# A machine image is a single static unit that contains a pre-configured operating system and
# installed software which is used to quickly create new running machines. Machine image formats
# change for each platform. Some examples include AMIs for EC2, VMDK/VMX files for VMware, OVF
# exports for VirtualBox, etc.
#
# For more details, please visit:
#   https://packer.io/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install hashicorp packer. ------------------------------------------------------------------------
packer_release="1.9.1"
packer_binary="packer_${packer_release}_linux_amd64.zip"
packer_sha256="793ed62255b9e572eda0c77d2a770f5fde501314b7598320786f1e51feb260d6"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download packer binary from hashicorp.com.
rm -f ${packer_binary}
wget --no-verbose https://releases.hashicorp.com/packer/${packer_release}/${packer_binary}

# verify the downloaded binary.
echo "${packer_sha256} ${packer_binary}" | sha256sum --check
# packer_${packer_release}_linux_amd64.zip: OK

# extract packer binary.
rm -f packer
unzip ${packer_binary}
chmod 755 packer
rm -f ${packer_binary}

# verify installation. -----------------------------------------------------------------------------
# set packer environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify packer version.
packer --version

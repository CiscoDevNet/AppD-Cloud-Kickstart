#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install K9s CLI cluster manager for Kubernetes.
#
# K9s - Kubernetes CLI To Manage Your Clusters In Style!
#
# K9s provides a terminal UI to interact with your Kubernetes clusters. The aim of this project is
# to make it easier to navigate, observe, and manage your applications in the wild. K9s continually
# watches Kubernetes for changes and offers subsequent commands to interact with your observed
# resources.
#
# For more details, please visit:
#   https://github.com/derailed/k9s
#   https://k9scli.io/topics/commands/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install k9s cli client. --------------------------------------------------------------------------
k9s_release="0.40.10"

# set the packer cli binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  k9s_binary="k9s_Linux_amd64.tar.gz"
  k9s_sha256="490bbfcb9314e59c0b1396e1d896786dc944fa9f83062296f454fef97aee0a54"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  k9s_binary="k9s_Linux_arm64.tar.gz"
  k9s_sha256="b1f12af342fbd21d466463132fd57eb9175b40ab98b5c711d3b249d3f507fc91"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download k9s from github.com.
rm -f ${k9s_binary}
curl --silent --location "https://github.com/derailed/k9s/releases/download/v${k9s_release}/${k9s_binary}" --output ${k9s_binary}
chmod 755 ${k9s_binary}

# verify the downloaded binary.
echo "${k9s_sha256} ${k9s_binary}" | sha256sum --check
# k9s_Linux_amd64.tar.gz: OK
# k9s_Linux_arm64.tar.gz: OK

# extract k9s cli binary.
rm -f k9s
tar -zxvf ${k9s_binary} --no-same-owner --no-overwrite-dir k9s
chown root:root k9s
rm -f ${k9s_binary}

# change execute permissions.
chmod 755 k9s

# set helm environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation. -----------------------------------------------------------------------------
k9s version
#k9s info

#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install eksctl CLI for Amazon EKS.
#
# eksctl is a simple CLI tool for creating clusters on EKS - Amazon's new managed Kubernetes
# service for EC2. It is written in Go, and uses CloudFormation.
#
# You can create a cluster in minutes with just one command: 'eksctl create cluster'!
#
# For more details, please visit:
#   https://github.com/weaveworks/eksctl
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install eksctl cli. ------------------------------------------------------------------------------
eksctl_release="0.205.0"

# set the eksctl cli binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  eksctl_binary="eksctl_$(uname -s)_amd64.tar.gz"
  eksctl_sha256="52f52276276d421f03790fbdc1b02e783c369f4863fc6dc83cf116f2f89ca5c4"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  eksctl_binary="eksctl_$(uname -s)_arm64.tar.gz"
  eksctl_sha256="182f1104fdf886d613eada1aee120bf7627d77d9886f30c3f78c28a5a3bf8c08"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download eksctl binary from github.com.
rm -f ${eksctl_binary}
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v${eksctl_release}/${eksctl_binary}" --output ${eksctl_binary}

# verify the downloaded binary.
echo "${eksctl_sha256} ${eksctl_binary}" | sha256sum --check
# eksctl_$(uname -s)_amd64.tar.gz: OK
# eksctl_$(uname -s)_arm64.tar.gz: OK

# extract eksctl binary.
rm -f eksctl
tar -zxvf ${eksctl_binary} --no-same-owner --no-overwrite-dir
chown root:root eksctl
rm -f ${eksctl_binary}

# change execute permissions.
chmod 755 eksctl

# set eksctl environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
eksctl version

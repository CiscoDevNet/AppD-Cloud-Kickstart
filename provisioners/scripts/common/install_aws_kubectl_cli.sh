#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install kubectl CLI for Amazon EKS.
#
# Kubernetes uses a command-line utility called kubectl for communicating with the cluster
# API server to deploy and manage applications on Kubernetes. Using kubectl, you can inspect
# cluster resources; create, delete, and update components; look at your new cluster; and
# bring up example apps.
#
# For more details, please visit:
#   https://kubernetes.io/docs/concepts/
#   https://kubernetes.io/docs/tasks/tools/install-kubectl/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install kubectl cli. -----------------------------------------------------------------------------
#kubectl_release="1.23.13"
#kubectl_date="2022-10-31"
#kubectl_sha256="e5e849f3ec6e1eb5265ea5f3ccb92531e4126dc1e7cfb0001e50aacb2a7e1229"
#kubectl_release="1.22.15"
#kubectl_date="2022-10-31"
#kubectl_sha256="56862c5f44629429dd3ef9e99a00d15b53bd71eec79a1f41e3ef9d2ce48ef2ca"
kubectl_release="1.21.14"
kubectl_date="2022-10-31"
kubectl_sha256="3df04a1eb35c3dd900e306ef0ed3ed522245c2a4acdb56d718d3cf19e1f1e36d"
#kubectl_release="1.20.15"
#kubectl_date="2022-10-31"
#kubectl_sha256="7e82f3c15c380c422218a12640f7fc054147386c8340356824bf2166892d5ac1"
#kubectl_release="1.19.6"
#kubectl_date="2021-01-05"
#kubectl_sha256="08ff68159bbcb844455167abb1d0de75bbfe5ae1b051f81ab060a1988027868a"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download kubectl binary from github.com.
rm -f kubectl
curl --silent --location "https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_release}/${kubectl_date}/bin/linux/amd64/kubectl" --output kubectl 
chown root:root kubectl

# verify the downloaded binary.
echo "${kubectl_sha256} kubectl" | sha256sum --check
# kubectl: OK

# change execute permissions.
chmod 755 kubectl

# set kubectl environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
kubectl version --short --client

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

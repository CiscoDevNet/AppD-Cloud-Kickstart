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
#kubectl_release="1.25.6"
#kubectl_date="2023-01-30"
#kubectl_sha256="96946285e6ac3f44ea604754e301d95ee21ccec8f8999b28361d2be04a71b6ee"
kubectl_release="1.24.10"
kubectl_date="2023-01-30"
kubectl_sha256="4122e22dafb80806cc850a2deda71e692921cf6c0f1de0fab87ef21a410a123a"
#kubectl_release="1.23.16"
#kubectl_date="2023-01-30"
#kubectl_sha256="96a017d093e52b779a99f08ec8c99fbef054c756a3610de1b7df11314f6168c3"
#kubectl_release="1.22.17"
#kubectl_date="2023-01-30"
#kubectl_sha256="e444b0470c1078e9ba8c3c953533e251b5c4ff141d1c4da962863d6f04a05b18"
#kubectl_release="1.21.14"
#kubectl_date="2023-01-30"
#kubectl_sha256="c85e4fc9be3c45a0eec59ac1d6ad74f79862544d06f641f847af62586dd94aeb"
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

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
kubectl_release="1.24.9"
kubectl_date="2023-01-11"
kubectl_sha256="2bbb2d1f87648f7cb5b88665a602f3d18d21dcf7551e126d0b3e29fe0c05bff5"
#kubectl_release="1.23.15"
#kubectl_date="2023-01-11"
#kubectl_sha256="a540a6aaa1182ca67c17208b6dc2c899d9942bd1ec83430b68a47cfe396d1c71"
#kubectl_release="1.22.17"
#kubectl_date="2023-01-11"
#kubectl_sha256="f934a8d350970f12ce01065b80c95bdfcd9b330f6147f89a3c470f91f38f9470"
#kubectl_release="1.21.14"
#kubectl_date="2023-01-11"
#kubectl_sha256="d85bee6d889ce52e54edcd57a798990b254148f7acb640bbf3aa5888f65786c3"
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

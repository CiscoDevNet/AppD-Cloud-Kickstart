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
kubectl_release="1.15.11"
#kubectl_release="1.17.7"
kubectl_date="2020-07-08"
kubectl_sha256="51903ec60d224639d23be3ec211049f2ccd88b335c973d9bf8ac356cc71af51c"
#kubectl_sha256="bba88f1635fc741fc9af52d3b3bd078e487c376de37fc669f8edcfd12e4f4f98"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download kubectl binary from github.com.
rm -f kubectl
curl --silent --location "https://amazon-eks.s3-us-west-2.amazonaws.com/${kubectl_release}/${kubectl_date}/bin/linux/amd64/kubectl" --output kubectl
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

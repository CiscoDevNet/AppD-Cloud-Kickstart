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
kubectl_release="1.27.4"
kubectl_date="2023-08-16"
kubectl_sha256="e761d2a253c2fb2b2ecd506fa54f878e30057000f8b20ec7ef88f6112f3ac845"
#kubectl_release="1.26.7"
#kubectl_date="2023-08-16"
#kubectl_sha256="634bb5b1c50922f43521defc4eedab80bbf5485027a0a700202ae7b996bce6cb"
#kubectl_release="1.25.12"
#kubectl_date="2023-08-16"
#kubectl_sha256="69478afcead0a5df3164f4a2923ee9bb74e7d81ac3facf90491b02e169f1d0a9"
#kubectl_release="1.24.16"
#kubectl_date="2023-08-16"
#kubectl_sha256="bd65a65f83c15d1946149df4c9dfe2d9b6e637cdc2afdd87826d3279a16f0faf"
#kubectl_release="1.23.17"
#kubectl_date="2023-08-16"
#kubectl_sha256="f449567ba30740c5f06428466a1d2a4562d1d2fdf2260a1ebe10dd8fb28a28ce"

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

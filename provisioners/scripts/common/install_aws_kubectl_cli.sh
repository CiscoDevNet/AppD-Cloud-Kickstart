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
#kubectl_release="1.26.4"
#kubectl_date="2023-05-11"
#kubectl_sha256="307eb9a77e269322969bc8249ae91ca61c8e1668436ef5746d4fcd1f6bef4586"
#kubectl_release="1.25.9"
#kubectl_date="2023-05-11"
#kubectl_sha256="270f136b893567f70d9b28d72cca35e7b5d145070d529932bbf386bb1741d2a2"
kubectl_release="1.24.13"
kubectl_date="2023-05-11"
kubectl_sha256="315d7d49192e5675a6e271401e2b37c310d82668ae5eb533e2b9fc53d27078d6"
#kubectl_release="1.23.17"
#kubectl_date="2023-05-11"
#kubectl_sha256="b48ae5c8c046762113b47fe057d469a30236ec96ef9d29329a26b087c877ae0f"
#kubectl_release="1.22.17"
#kubectl_date="2023-05-11"
#kubectl_sha256="5c69d431cf829271d38db563b35e076c41ce1f14202df56f6f4e2856054e0b01"
#kubectl_release="1.21.14"
#kubectl_date="2023-01-30"
#kubectl_sha256="c85e4fc9be3c45a0eec59ac1d6ad74f79862544d06f641f847af62586dd94aeb"
#kubectl_release="1.20.15"
#kubectl_date="2022-10-31"
#kubectl_sha256="7e82f3c15c380c422218a12640f7fc054147386c8340356824bf2166892d5ac1"

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

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
#kubectl_release="1.26.2"
#kubectl_date="2023-03-17"
#kubectl_sha256="25268c0712138d9f6e02fe0b9cf39154ecac02d21ba97c39766fb7d99da1f9ad"
#kubectl_release="1.25.7"
#kubectl_date="2023-03-17"
#kubectl_sha256="742b1bd2fa88404e21df8196e919f22b7edd06c3536cbfe347174edfea4516c0"
kubectl_release="1.24.11"
kubectl_date="2023-03-17"
kubectl_sha256="a96a5e97b79d7347d49ae1583c5531f2f565418cb28ee08b56b83f4c794e6210"
#kubectl_release="1.23.17"
#kubectl_date="2023-03-17"
#kubectl_sha256="2f37f179c4d3c0b82cf35338524fad94180da1f7a98cc5e347b9d582c02c827c"
#kubectl_release="1.22.17"
#kubectl_date="2023-03-17"
#kubectl_sha256="2df4260b3852158f49dc4b8f6f57133f46ca27d02cd5bc65425038dba943a213"
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

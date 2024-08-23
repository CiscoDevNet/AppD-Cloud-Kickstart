#!/bin/bash -eux
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
#kubectl_release="1.30.2"
#kubectl_date="2024-07-12"
#kubectl_sha256="2d40dfbdfcfb7abe153d5e7818bdf897f841b0dfd6a028bb15cd763cfe6955b4"
kubectl_release="1.29.6"
kubectl_date="2024-07-12"
kubectl_sha256="06e6f1c6bbb739c15801c5b6b9953cfb79b465269ae747aabe6c75c12da014c1"
#kubectl_release="1.28.11"
#kubectl_date="2024-07-12"
#kubectl_sha256="7a6835e4b9430e483f1de300d1cd183d688b32d8032e418491f68b2ece98832b"
#kubectl_release="1.27.15"
#kubectl_date="2024-07-12"
#kubectl_sha256="2457959e5324acdbc8961405e2f22dd5097074102f846a52e538f1fab8d80689"
#kubectl_release="1.26.15"
#kubectl_date="2024-07-12"
#kubectl_sha256="6057e856a7c37814d63aca79a7190d7adbc801123aa347ae8bf4fcc4b32502ca"
#kubectl_release="1.25.16"
#kubectl_date="2024-07-12"
#kubectl_sha256="533b21d213ed122e5eb6e3c52e27379c5847567db756879a027f4392f3ab7656"
#kubectl_release="1.24.17"
#kubectl_date="2024-07-12"
#kubectl_sha256="7e6ef09a2b41131d5fdcb4ef690cd1abd5241610fff61b35d25ba0f328291122"
#kubectl_release="1.23.17"
#kubectl_date="2024-07-12"
#kubectl_sha256="125f4dd17040566fd6c706b4ff6c8fce522526723e0178e7aca39004fc5d887a"

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
if [[ "$kubectl_release" < "1.28.0" ]]; then
  kubectl version --short --client
else
  kubectl version --client
fi

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

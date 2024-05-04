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
kubectl_release="1.29.3"
kubectl_date="2024-04-19"
kubectl_sha256="50deb7360a21bcaa6a0eb312cc0e25a7bf62c9097a3774d84fc6011500c6e2eb"
#kubectl_release="1.28.8"
#kubectl_date="2024-04-19"
#kubectl_sha256="fc260d9f85cd5fe844f6b8a9c215f7a82748c228944c68535d2acc7652dca5b8"
#kubectl_release="1.27.12"
#kubectl_date="2024-04-19"
#kubectl_sha256="9e3c75acf52027c6141e6b0a5f80bc1c206d147732ace1e08a04525f5d36a57f"
#kubectl_release="1.26.15"
#kubectl_date="2024-04-19"
#kubectl_sha256="788713be1b80b94ccfde79bd2fd8b196f8296ea3c5356e44ab8e62358d2f8d69"
#kubectl_release="1.25.16"
#kubectl_date="2024-04-19"
#kubectl_sha256="0248c05e1d42b0376c3cc95889fbd342f66eb3e65fd02d8d5b2ad7782b5431bf"
#kubectl_release="1.24.17"
#kubectl_date="2024-04-19"
#kubectl_sha256="77b18e33dd2fe6ba96e314084dbf8ec95f51a55e7becfe27fafc1325029e9d53"
#kubectl_release="1.23.17"
#kubectl_date="2024-04-19"
#kubectl_sha256="002370fa9f628a72292187045e2afcb6c6fada4aa77b40717f5c6a3886970c35"

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

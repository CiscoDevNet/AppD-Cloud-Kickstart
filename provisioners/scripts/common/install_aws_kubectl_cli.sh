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
kubectl_release="1.28.3"
kubectl_date="2023-11-14"
kubectl_sha256="3b9ffe2effbfc12a30b12739126f069fe8a7f13625e71ccb82c33ad1ea8f8092"
#kubectl_release="1.27.7"
#kubectl_date="2023-11-14"
#kubectl_sha256="d2351de8ebcebb4a3ba1a3daf359910b93460a0b71db93f4f83ddfabcd0ed041"
#kubectl_release="1.26.10"
#kubectl_date="2023-11-14"
#kubectl_sha256="b55a9aa731e79b824812555c0f8671e00e03b3e2a41403134b8c2f883506fdb6"
#kubectl_release="1.25.15"
#kubectl_date="2023-11-14"
#kubectl_sha256="d08fe44203e0798ec34d7cd4721202bebafc9b3f3b5bca5c9a62f15e58423260"
#kubectl_release="1.24.17"
#kubectl_date="2023-11-14"
#kubectl_sha256="ef774c10dbfbff8a593c8761796794e5f7ef19f8fd4672c6321b0fa5722a76be"
#kubectl_release="1.23.17"
#kubectl_date="2023-11-14"
#kubectl_sha256="8ebc59c645d59b2b3f4d69485ef4abbd1f3b9461a7e5cf7222a5c85abc3f5aee"

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
case $kubectl_release in
  1.28.3|1.29.0)
    kubectl version --client
    ;;
  *)
    kubectl version --short --client
    ;;
esac

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

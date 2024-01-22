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
kubectl_release="1.28.5"
kubectl_date="2024-01-04"
kubectl_sha256="bf039cfa331ed5edd47877ab37ee078ae1af3ea500958750eba74638211e8085"
#kubectl_release="1.27.9"
#kubectl_date="2024-01-04"
#kubectl_sha256="7b132591fd333cb6714f1bd81ea5e87eef9f466ccb790f3dfda8b4890eddd339"
#kubectl_release="1.26.12"
#kubectl_date="2024-01-04"
#kubectl_sha256="75c6bd79dd4348e23171ec2138aa1d299351415b649f9ba046c602a6da6f83a6"
#kubectl_release="1.25.16"
#kubectl_date="2024-01-04"
#kubectl_sha256="1ae03e528034c64b5bca600146b202a1cafbc8f19a7fc0e4d4b6fed4a453a9cc"
#kubectl_release="1.24.17"
#kubectl_date="2024-01-04"
#kubectl_sha256="10cf62d967f4418ebbd6c5684f3897d0370264d0c5f18a4ab2350f52cfe84d7d"
#kubectl_release="1.23.17"
#kubectl_date="2024-01-04"
#kubectl_sha256="25d77fe0380c4eb0ca8e3b2c200bfb123db50b5a26694c6a25b75cda366585c9"

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
  1.28.5|1.29.0)
    kubectl version --client
    ;;
  *)
    kubectl version --short --client
    ;;
esac

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

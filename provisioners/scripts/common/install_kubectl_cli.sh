#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install kubectl CLI for Linux.
#
# Kubernetes uses a command-line utility called kubectl for communicating with the cluster
# API server to deploy and manage applications on Kubernetes. Using kubectl, you can inspect
# cluster resources; create, delete, and update components; look at your new cluster; and
# bring up example apps.
#
# For more details, please visit:
#   https://kubernetes.io/docs/concepts/
#   https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
#   https://github.com/kubernetes/kubectl
#
# To list supported Kubernetes versions for GKE in a specific region/zone:
#   gcloud container get-server-config --region=us-central1
#   gcloud container get-server-config --zone=us-central1-a
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] kubectl install parameters [w/ defaults].
#kubectl_release="${kubectl_release:-1.31.0}"
#kubectl_sha256="${kubectl_sha256:-7c27adc64a84d1c0cc3dcf7bf4b6e916cc00f3f576a2dbac51b318d926032437}"
#kubectl_release="${kubectl_release:-1.30.4}"
#kubectl_sha256="${kubectl_sha256:-2ffd023712bbc1a9390dbd8c0c15201c165a69d394787ef03eda3eccb4b9ac06}"
kubectl_release="${kubectl_release:-1.29.8}"
kubectl_sha256="${kubectl_sha256:-038454e0d79748aab41668f44ca6e4ac8affd1895a94f592b9739a0ae2a5f06a}"
#kubectl_release="${kubectl_release:-1.28.13}"
#kubectl_sha256="${kubectl_sha256:-d7d363dd5a4c95444329bc5239b8718ebe84a043052958b2f15ee2feef9a28c6}"
#kubectl_release="${kubectl_release:-1.27.16}"
#kubectl_sha256="${kubectl_sha256:-97ea7cd771d0c6e3332614668a40d2c5996f0053ff11b44b198ea84dba0818cb}"
#kubectl_release="${kubectl_release:-1.26.15}"
#kubectl_sha256="${kubectl_sha256:-b75f359e6fad3cdbf05a0ee9d5872c43383683bb8527a9e078bb5b8a44350a41}"
#kubectl_release="${kubectl_release:-1.25.16}"
#kubectl_sha256="${kubectl_sha256:-5a9bc1d3ebfc7f6f812042d5f97b82730f2bdda47634b67bddf36ed23819ab17}"
#kubectl_release="${kubectl_release:-1.24.17}"
#kubectl_sha256="${kubectl_sha256:-3e9588e3326c7110a163103fc3ea101bb0e85f4d6fd228cf928fa9a2a20594d5}"
#kubectl_release="${kubectl_release:-1.23.17}"
#kubectl_sha256="${kubectl_sha256:-f09f7338b5a677f17a9443796c648d2b80feaec9d6a094ab79a77c8a01fde941}"
#kubectl_release="${kubectl_release:-1.22.17}"
#kubectl_sha256="${kubectl_sha256:-7506a0ae7a59b35089853e1da2b0b9ac0258c5309ea3d165c3412904a9051d48}"
#kubectl_release="${kubectl_release:-1.21.14}"
#kubectl_sha256="${kubectl_sha256:-0c1682493c2abd7bc5fe4ddcdb0b6e5d417aa7e067994ffeca964163a988c6ee}"
#kubectl_release="${kubectl_release:-1.20.15}"
#kubectl_sha256="${kubectl_sha256:-d283552d3ef3b0fd47c08953414e1e73897a1b3f88c8a520bb2e7de4e37e96f3}"
#kubectl_release="${kubectl_release:-1.19.16}"
#kubectl_sha256="${kubectl_sha256:-6b9d9315877c624097630ac3c9a13f1f7603be39764001da7a080162f85cbc7e}"
#kubectl_release="${kubectl_release:-1.18.19}"
#kubectl_sha256="${kubectl_sha256:-332820433bc7695801bcf6e8444856fc7daae97fc9261b918d491110d67be116}"

# install kubectl cli. -----------------------------------------------------------------------------
# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download kubectl binary from github.com.
rm -f kubectl
curl --silent --location "https://dl.k8s.io/release/v${kubectl_release}/bin/linux/amd64/kubectl" --output kubectl
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

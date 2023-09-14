#!/bin/sh -eux
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
#kubectl_release="${kubectl_release:-1.28.2}"
#kubectl_sha256="${kubectl_sha256:-c922440b043e5de1afa3c1382f8c663a25f055978cbc6e8423493ec157579ec5}"
kubectl_release="${kubectl_release:-1.27.6}"
kubectl_sha256="${kubectl_sha256:-2b7adb71c8630904da1b94e262c8c3c477e9609b3c0ed8ae1213a1e156ae38dd}"
#kubectl_release="${kubectl_release:-1.26.9}"
#kubectl_sha256="${kubectl_sha256:-98ea4a13895e54ba24f57e0d369ff6be0d3906895305d5390197069b1da12ae2}"
#kubectl_release="${kubectl_release:-1.25.14}"
#kubectl_sha256="${kubectl_sha256:-06351e043b8ecd1206854643a2094ccf218180c1b3fab5243f78d2ccfc630ca2}"
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
kubectl version --short --client

#export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

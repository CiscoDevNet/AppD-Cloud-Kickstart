#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Helm CLI package manager for Kubernetes.
#
# Helm is a tool that streamlines installing and managing Kubernetes applications.
# Think of it like apt/yum/homebrew for Kubernetes.
#
# - Helm has two parts: a client (`helm`) and a server (`tiller`)
# - Tiller runs inside of your Kubernetes cluster, and manages releases (installations)
#   of your charts.
# - Helm runs on your laptop, CI/CD, or wherever you want it to run.
# - Charts are Helm packages that contain at least two things:
#   - A description of the package (`Chart.yaml`)
#   - One or more templates, which contain Kubernetes manifest files
# - Charts can be stored on disk, or fetched from remote chart repositories
#   (like Debian or RedHat packages)
#
# For more details, please visit:
#   https://helm.sh
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install helm cli client. -------------------------------------------------------------------------
helm_folder="linux-amd64"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-helm.${curdate}.out1 https://github.com/helm/helm/releases/latest --output /dev/null
tr -d '\r' < curl-helm.${curdate}.out1 > curl-helm.${curdate}.out2
helm_release=$(awk '/Location/ {print $2}' curl-helm.${curdate}.out2 | awk -F "/" '{print $8}')
helm_binary="helm-${helm_release}-linux-amd64.tar.gz"
rm -f curl-helm.${curdate}.out1
rm -f curl-helm.${curdate}.out2

# download helm from github.com.
rm -f ${helm_binary}
rm -Rf ${helm_folder}
curl --silent --location "https://storage.googleapis.com/kubernetes-helm/${helm_binary}" --output ${helm_binary}
chmod 755 ${helm_binary}

# extract helm binaries.
rm -f helm tiller
tar -zxvf ${helm_binary} --no-same-owner --no-overwrite-dir
chown root:root ${helm_folder}
cp ./${helm_folder}/helm .
cp ./${helm_folder}/tiller .
rm -f ${helm_binary}
rm -Rf ${helm_folder}

# change execute permissions.
chmod 755 helm tiller

# set helm environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
helm version --client
tiller -version

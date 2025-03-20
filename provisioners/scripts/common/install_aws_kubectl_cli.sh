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

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# install kubectl cli. -----------------------------------------------------------------------------
#kubectl_release="1.32.0"
#kubectl_date="2024-12-20"
kubectl_release="1.31.3"
kubectl_date="2024-12-12"
#kubectl_release="1.30.7"
#kubectl_date="2024-12-12"
#kubectl_release="1.29.10"
#kubectl_date="2024-12-12"
#kubectl_release="1.28.15"
#kubectl_date="2024-12-12"
#kubectl_release="1.27.16"
#kubectl_date="2024-12-12"
#kubectl_release="1.26.15"
#kubectl_date="2024-12-12"
#kubectl_release="1.25.16"
#kubectl_date="2024-12-12"
#kubectl_release="1.24.17"
#kubectl_date="2024-12-12"
#kubectl_release="1.23.17"
#kubectl_date="2024-09-11"

# declare associative array for the sha256 values.
declare -A sha256_values_array

# set the kubectl cli binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 sha256 values.
  sha256_values_array["1.32.0"]="3d46610a1eba3dd47e4879f69effa481f56517d7a4a57bb3ebf7498f4df2e99e"
  sha256_values_array["1.31.3"]="9b14b506556ce59800319128a591a0a04b32196131e672e0f13b8e91ed611128"
  sha256_values_array["1.30.7"]="5754717b7a6dd931245e4643b867701f50e7f5a4c93626216c4b738af45e6866"
  sha256_values_array["1.29.10"]="260fe18665dab11f5b075c11003e87a606cf4c2418e723a41f9218505c8fc8b6"
  sha256_values_array["1.28.15"]="12e36b5275ff9510064bb7d27d54f53c43dfab080917a9e28493fb629a0f9938"
  sha256_values_array["1.27.16"]="1813737d0997f372a1be2da6897a638e2a7eb81e5f828e0e0e724f05c50256aa"
  sha256_values_array["1.26.15"]="4dea29aaca9314d089bd8b1829f9c3dec02618c2e44064e92271559175811e24"
  sha256_values_array["1.25.16"]="f8850275ba4f5fbd15474a5ccf5903ab80447ca5396841a2b17ab7ddddf6a114"
  sha256_values_array["1.24.17"]="f4e5ccff4b212507ff2864947b04fcbf68d68cb0f1c4a562fa33e301907c3626"
  sha256_values_array["1.23.17"]="23b46e400d3594d7de611e116746269656d828db7de129c86767a6acf7322d1f"

  # set the amd64 download path.
  kubectl_path="amd64"

elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 sha256 values.
  sha256_values_array["1.32.0"]="d53a6d7f902809e3e8114801903c1f145ab40e1cb4735d9921559620ac1a0988"
  sha256_values_array["1.31.3"]="326327b6449bc0880ab2c173faeb00037ad3d1daa4b8437e3b90f918d631aee5"
  sha256_values_array["1.30.7"]="1ab4d6b90134ea845b478f7596cb051c4a2384d1db1135d000530d27fbbbdab2"
  sha256_values_array["1.29.10"]="fbf741880f192e640da1c32b2af6dab5f84d0c58c55f0282fc92b4fb65fef001"
  sha256_values_array["1.28.15"]="ffc372c4bc25f803114ccbbebcc3541dae0e6a7b135125ab8a245a0679606725"
  sha256_values_array["1.27.16"]="7e103cb0081e88eeccfcae2e9c4616135b289558f5b4fe644fab21a52d36c8c8"
  sha256_values_array["1.26.15"]="f974aee8355790d6b9848c42d64898308a2e2c084c3437a5d720c6444e317db3"
  sha256_values_array["1.25.16"]="329b919f9857f5fe35481d2eb5b1ea30c3a504e39505f540228dd631e0b6b5e0"
  sha256_values_array["1.24.17"]="882ca847ba68622416a1e70b2a17ae28febf82e8da0ef1b6d94084fcb65329d9"
  sha256_values_array["1.23.17"]="721a76d9f9d60cbfaafec1a88f554d324c6750517d17b0d1c59e53ef3483f6f5"

  # set the arm64 download path.
  kubectl_path="arm64"

else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download kubectl binary from github.com.
rm -f kubectl
curl --silent --location "https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_release}/${kubectl_date}/bin/linux/${kubectl_path}/kubectl" --output kubectl
chown root:root kubectl

# verify the downloaded binary.
echo "${sha256_values_array[${kubectl_release}]} kubectl" | sha256sum --check
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

#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Grafana Tanka CLI configuration utility for Kubernetes.
#
# Grafana Tanka is the robust configuration utility for your Kubernetes cluster, powered by the
# unique Jsonnet language. It is the clean, concise, and super flexible alternative to YAML:
#
# - Clean: The Jsonnet language expresses your apps more obviously than YAML ever did.
# - Reusable: Build libraries, import them anytime and even share them on GitHub!
# - Concise: Using the Kubernetes library and abstraction, you will never see boilerplate again!
# - Confidence: Stop guessing and use tk diff to see what exactly will happen.
# - Helm: Vendor in, modify, and export Helm charts reproducibly.
# - Production ready: Tanka deploys Grafana Cloud and many more production setups.
#
# Tanka is distributed as a single binary called 'tk'. It already includes the Jsonnet compiler,
# but requires some additional tools to be available:
#
# - kubectl: Tanka uses 'kubectl' to communicate with your cluster.
# - diff: To compute differences, standard UNIX diff(1) is required.
# - jb: The Jsonnet Bundler is the Jsonnet package manager. [recommended] 
# - helm: Helm is also needed for Helm support. [recommended] 
#
# For more details, please visit:
#   https://github.com/grafana/tanka
#   https://tanka.dev/
#   https://tanka.dev/install/
#
# NOTE: Script should be run with 'root' privilege.
#       To generate sha256 checksum on MacOS, run: 'shasum -a 256 tk-linux-amd64' --and--
#                                             run: 'shasum -a 256 tk-linux-arm64'
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] tanka install parameters [w/ defaults].
#####user_name="${user_name:-centos}"

# retrieve the current cpu architecture. -----------------------------------------------------------
cpu_arch=$(uname -m)

# define tanka input variables. --------------------------------------------------------------------
tanka_release="0.31.3"

# set the tk cli binary and sha256 values based on cpu architecture.
if [ "$cpu_arch" = "x86_64" ]; then
  # set the amd64 variables.
  tanka_binary="tk-linux-amd64"
  tanka_sha256="c10907f25aacebf40e03604b20afa9d94a968c489008bdff5d283a959c7eacdf"
elif [ "$cpu_arch" = "aarch64" ]; then
  # set the arm64 variables.
  tanka_binary="tk-linux-arm64"
  tanka_sha256="46c4bb4f79054f9578db63cad54d05b02c5c8b64590129416e6f1360bdaa8f0f"
else
  echo "Error: Unsupported CPU architecture: '${cpu_arch}'."
  exit 1
fi

# check for required and recommended utilities. ----------------------------------------------------
# check if 'kubectl' is installed.
if [ ! -f "/usr/local/bin/kubectl" ] && [ ! -f "/opt/homebrew/bin/kubectl" ]; then
  set +x  # temporarily turn command display OFF.
  echo "Error: 'kubectl' command-line utility not found."
  echo "NOTE: This script requires the 'kubectl' command-line utility."
  echo "      For more information, visit: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
  set -x  # turn command display back ON.
  exit 1
fi

# check if jsonnet-bundler 'jb' command-line utility is installed.
if [ ! -f "/usr/local/bin/jb" ] && [ ! -f "/opt/homebrew/bin/jb" ]; then
  set +x  # temporarily turn command display OFF.
  echo "Warning: jsonnet-bundler 'jb' command-line utility not found."
  echo "NOTE: This script recommends installing the jsonnet-bundler 'jb' command-line utility."
  echo "      For more information, visit: https://github.com/jsonnet-bundler/jsonnet-bundler"
  echo "                                   https://tanka.dev/install/"
  echo ""
  set -x  # turn command display back ON.
fi

# check if 'helm' is installed.
if [ ! -f "/usr/local/bin/helm" ] && [ ! -f "/opt/homebrew/bin/helm" ]; then
  set +x  # temporarily turn command display OFF.
  echo "Warning: 'helm' command-line utility not found."
  echo "NOTE: This script recommends installing the 'helm' command-line utility."
  echo "      For more information, visit: https://helm.sh/"
  echo ""
  set -x  # turn command display back ON.
fi

# check for required and recommended utilities (alternate method). ---------------------------------
# check if 'kubectl' command-line utility is installed.
#####path_to_kubectl=$(runuser -c "which kubectl" - ${user_name})
#####if [ ! -x "$path_to_kubectl" ] ; then
#####  set +x  # temporarily turn command display OFF.
#####  echo "Error: 'kubectl' command-line utility not found."
#####  echo "NOTE: This script requires the 'kubectl' command-line utility."
#####  echo "      For more information, visit: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
#####  set -x  # turn command display back ON.
#####  exit 1
#####fi

# check if jsonnet-bundler 'jb' command-line utility is installed.
#####path_to_jb=$(runuser -c "which jb" - ${user_name})
#####if [ ! -x "$path_to_jb" ] ; then
#####  set +x  # temporarily turn command display OFF.
#####  echo "Warning: jsonnet-bundler 'jb' command-line utility not found."
#####  echo "NOTE: This script recommends installing the jsonnet-bundler 'jb' command-line utility."
#####  echo "      For more information, visit: https://github.com/jsonnet-bundler/jsonnet-bundler"
#####  echo "                                   https://tanka.dev/install/"
#####  echo ""
#####  set -x  # turn command display back ON.
#####fi

# check if 'helm' command-line utility is installed.
#####path_to_helm=$(runuser -c "which helm" - ${user_name})
#####if [ ! -x "$path_to_helm" ] ; then
#####  set +x  # temporarily turn command display OFF.
#####  echo "Warning: 'helm' command-line utility not found."
#####  echo "NOTE: This script recommends installing the 'helm' command-line utility."
#####  echo "      For more information, visit: https://helm.sh/"
#####  echo ""
#####  set -x  # turn command display back ON.
#####fi

# install tanka cli client. ------------------------------------------------------------------------
# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download tanka from github.com.
rm -f tk
curl --silent --location "https://github.com/grafana/tanka/releases/download/v${tanka_release}/${tanka_binary}" --output tk
###curl --silent --location "https://github.com/grafana/tanka/releases/latest/download/${tanka_binary}" --output tk

# change owner and execute permissions.
chown root:root tk
chmod 755 tk

# verify the downloaded binary.
echo "${tanka_sha256} tk" | sha256sum --check
# tk: OK

# set tk environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation. -----------------------------------------------------------------------------
tk --version

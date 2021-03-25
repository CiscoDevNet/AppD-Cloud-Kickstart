#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Cluster Agent by AppDynamics.
#
# The Cluster Agent is a lightweight Agent written in Golang for monitoring Kubernetes and
# OpenShift clusters. The Cluster Agent helps you monitor and understand how Kubernetes
# infrastructure affects your applications and business performance. With the Cluster Agent, you
# can collect metadata, metrics, and events for a Kubernetes cluster. The Cluster Agent works on
# Red Hat OpenShift and cloud-based Kubernetes platforms, such as: Amazon EKS, Azure AKS, and
# Google GKE.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Monitoring+Kubernetes+with+the+Cluster+Agent
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       This script requires the 'kubectl' command-line utility to communicate with the Kubernetes cluster.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics account parameters.
set +x  # temporarily turn command display OFF.
appd_username="${appd_username:-}"
appd_password="${appd_password:-}"
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics cluster agent install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"

set +x  # temporarily turn command display OFF.
appd_controller_admin_username="${appd_controller_admin_username:-admin}"
appd_controller_admin_password="${appd_controller_admin_password:-welcome1}"
set -x  # turn command display back ON.

appd_cluster_agent_home="${appd_cluster_agent_home:-cluster-agent}"
appd_cluster_agent_user="${appd_cluster_agent_user:-centos}"
appd_cluster_agent_user_group="${appd_cluster_agent_user_group:-centos}"
appd_cluster_agent_release="${appd_cluster_agent_release:-21.2.0.1997}"
appd_cluster_agent_sha256="${appd_cluster_agent_sha256:-c191cba91d13dfb01e29b43125943f7bd96638db654385ab32c9af18d2c982bb}"

# [OPTIONAL] appdynamics cluster agent config parameters [w/ defaults].
appd_install_kubernetes_metrics_server="${appd_install_kubernetes_metrics_server:-true}"
appd_cluster_agent_auto_instrumentation="${appd_cluster_agent_auto_instrumentation:-false}"
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_cluster_agent_account_name="${appd_cluster_agent_account_name:-customer1}"
appd_cluster_agent_account_access_key="${appd_cluster_agent_account_access_key:-abcdef01-2345-6789-abcd-ef0123456789}"
appd_cluster_agent_docker_image="${appd_cluster_agent_docker_image:-docker.io/appdynamics/cluster-agent:latest}"
appd_cluster_agent_application_name="${appd_cluster_agent_application_name:-My-App}"
appd_cluster_agent_tier_name="${appd_cluster_agent_tier_name:-My-App-Web-Tier}"
appd_cluster_agent_node_name="${appd_cluster_agent_node_name:-Development}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Cluster Agent by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        This script requires the 'kubectl' command-line utility to communicate with the Kubernetes cluster.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] appdynamics account parameters.
    [root]# export appd_username="name@example.com"                     # user name for downloading binaries.
    [root]# export appd_password="password"                             # user password.

  [OPTIONAL] appdynamics cluster agent install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_controller_admin_username="admin"               # [optional] controller admin user name (defaults to 'admin').
    [root]# export appd_controller_admin_password="welcome1"            # [optional] controller admin password (defaults to 'welcome1').
    [root]# export appd_cluster_agent_home="cluster-agent"              # [optional] cluster agent home (defaults to 'cluster-agent').
    [root]# export appd_cluster_agent_user="centos"                     # [optional] cluster agent user (defaults to user 'centos').
    [root]# export appd_cluster_agent_user_group="centos"               # [optional] cluster agent group (defaults to group 'centos').
    [root]# export appd_cluster_agent_release="21.2.0.1997"             # [optional] cluster agent release (defaults to '21.2.0.1997').
                                                                        # [optional] cluster agent sha-256 checksum (defaults to published value).
    [root]# export appd_cluster_agent_sha256="c191cba91d13dfb01e29b43125943f7bd96638db654385ab32c9af18d2c982bb"

  [OPTIONAL] appdynamics cluster agent config parameters [w/ defaults].
    [root]# export appd_install_kubernetes_metrics_server="true"        # [optional] install kubernetes metrics server? [boolean] (defaults to 'true').
    [root]# export appd_cluster_agent_auto_instrumentation="true"       # [optional] configure cluster agent auto instrumentation? [boolean] (defaults to 'false').
    [root]# export appd_controller_host="apm"                           # [optional] controller host (defaults to 'apm').
    [root]# export appd_controller_port="8090"                          # [optional] controller port (defaults to '8090').
    [root]# export appd_cluster_agent_account_name="customer1"          # [optional] account name (defaults to 'customer1').
                                                                        # [optional] account access key (defaults to <placeholder_value>).
    [root]# export appd_cluster_agent_account_access_key="abcdef01-2345-6789-abcd-ef0123456789"
                                                                        # [optional] appd cluster agent docker image (defaults to 'docker.io/appdynamics/cluster-agent:latest').
    [root]# export appd_cluster_agent_docker_image="edbarberis/cluster-agent:latest"
    [root]# export appd_cluster_agent_application_name="My-App"         # [optional] associate cluster agent with application (defaults to ''My-App).
    [root]# export appd_cluster_agent_tier_name="My App Web Tier"       # [optional] associate cluster agent with tier (defaults to 'My-App-Web-Tier').
    [root]# export appd_cluster_agent_node_name="Development"           # [optional] associate cluster agent with node (defaults to 'Development').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
set +x  # temporarily turn command display OFF.
if [ -z "$appd_username" ]; then
  echo "Error: 'appd_username' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_password" ]; then
  echo "Error: 'appd_password' environment variable not set."
  usage
  exit 1
fi
set -x  # turn command display back ON.

# check if 'kubectl' command-line utility is installed. --------------------------------------------
path_to_kubectl=$(runuser -c "which kubectl" - ${appd_cluster_agent_user})
if [ ! -x "$path_to_kubectl" ] ; then
  echo "Error: 'kubectl' command-line utility not found."
  echo "NOTE: This script requires the 'kubectl' command-line utility to communicate with the Kubernetes cluster."
  echo "      For more information, visit: https://kubernetes.io/docs/reference/kubectl/overview/"
fi

# set appdynamics cluster agent installation variables. --------------------------------------------
appd_cluster_agent_folder="${appd_cluster_agent_home}-${appd_cluster_agent_release}"
appd_cluster_agent_binary="appdynamics-cluster-agent-alpine-linux-${appd_cluster_agent_release}.zip"

# create appdynamics cluster agent parent folder. --------------------------------------------------
mkdir -p ${appd_home}/${appd_cluster_agent_folder}
cd ${appd_home}/${appd_cluster_agent_folder}

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# download the appdynamics cluster agent. ----------------------------------------------------------
# authenticate to the appdynamics domain and store the oauth token to a file.
post_data_filename="post-data.${curdate}.json"
oauth_token_filename="oauth-token.${curdate}.json"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"

set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"username\": \"${appd_username}\"," >> ${post_data_filename}
echo "  \"password\": \"${appd_password}\"," >> ${post_data_filename}
echo "  \"scopes\": [\"download\"]" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token --output ${oauth_token_filename}
oauth_token=$(awk -F '"' '{print $10}' ${oauth_token_filename})

# download the appdynamics cluster agent binary.
rm -f ${appd_cluster_agent_binary}
curl --silent --location --remote-name --header "Authorization: Bearer ${oauth_token}" https://download.appdynamics.com/download/prox/download-file/cluster-agent/${appd_cluster_agent_release}/${appd_cluster_agent_binary}
chmod 644 ${appd_cluster_agent_binary}

rm -f ${post_data_filename}
rm -f ${oauth_token_filename}

# verify the downloaded binary.
echo "${appd_cluster_agent_sha256} ${appd_cluster_agent_binary}" | sha256sum --check
# appdynamics-cluster-agent-alpine-linux-${appd_cluster_agent_release}.zip: OK

# extract appdynamics cluster agent binary.
unzip ${appd_cluster_agent_binary}
rm -f ${appd_cluster_agent_binary}
cd ${appd_home}
rm -f ${appd_cluster_agent_home}
ln -s ${appd_cluster_agent_folder} ${appd_cluster_agent_home}
chown -R ${appd_cluster_agent_user}:${appd_cluster_agent_user_group} .

# install the kubernetes metrics server. -----------------------------------------------------------
if [ "$appd_install_kubernetes_metrics_server" == "true" ]; then
  # download the metrics server components yaml file.
  metrics_server_url=$(curl --silent https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest | awk '/browser_download_url/ {print substr($2, 2, length($2)-2)}')
  #metrics_server_url=$(curl --silent https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest | jq -r '.assets[] | .browser_download_url')

  cd ${appd_home}/${appd_cluster_agent_home}
  curl --silent --location ${metrics_server_url} --output metrics-server-components.yaml
  chown -R ${appd_cluster_agent_user}:${appd_cluster_agent_user_group} metrics-server-components.yaml

  # deploy the metrics server.
  runuser -c "kubectl create -f ${appd_home}/${appd_cluster_agent_home}/metrics-server-components.yaml" - ${appd_cluster_agent_user}
  runuser -c "kubectl get pods -n kube-system" - ${appd_cluster_agent_user}
fi

# create the 'appdynamics' namespace in kubernetes. ------------------------------------------------
runuser -c "kubectl create namespace appdynamics" - ${appd_cluster_agent_user}
runuser -c "kubectl get namespace" - ${appd_cluster_agent_user}

# deploy the appdynamics cluster agent operator. ---------------------------------------------------
runuser -c "kubectl create -f ${appd_home}/${appd_cluster_agent_home}/cluster-agent-operator.yaml" - ${appd_cluster_agent_user}
runuser -c "kubectl get pods -n appdynamics" - ${appd_cluster_agent_user}

# create the cluster agent secret. -----------------------------------------------------------------
# for auto instrumentation, create a cluster agent secret with both the controller access key and api client credentials.
if [ "$appd_cluster_agent_auto_instrumentation" == "true" ]; then
  set +x  # temporarily turn command display OFF.
  runuser -c \
    "kubectl -n appdynamics \
       create secret generic cluster-agent-secret \
       --from-literal=controller-key=${appd_cluster_agent_account_access_key} \
       --from-literal=api-user=${appd_controller_admin_username}@${appd_cluster_agent_account_name}:${appd_controller_admin_password}" \
     - ${appd_cluster_agent_user}
  set -x  # turn command display back ON.
# otherwise, create a cluster agent secret with just the controller access key.
else
  runuser -c \
    "kubectl -n appdynamics \
       create secret generic cluster-agent-secret \
       --from-literal=controller-key=${appd_cluster_agent_account_access_key}" \
     - ${appd_cluster_agent_user}
fi

# configure appdynamics cluster agent. -------------------------------------------------------------
# set appdynamics cluster agent configuration variables.
appd_agent_config_path="${appd_home}/${appd_cluster_agent_home}"
appd_agent_config_file="cluster-agent.yaml"

# escape appdyamics cluster agent sting because it contains '/'s.
appd_cluster_agent_docker_image_escaped=$(printf '%s' "${appd_cluster_agent_docker_image}" | sed -e 's/[\/&]/\\&/g')

cd ${appd_agent_config_path}

# save a copy of the current file.
if [ -f "${appd_agent_config_file}.orig" ]; then
  cp -p ${appd_agent_config_file} ${appd_agent_config_file}.${curdate}
else
  cp -p ${appd_agent_config_file} ${appd_agent_config_file}.orig
fi

# use the stream editor to substitute the new values.
sed -i -e "/^  appName:/s/^.*$/  appName: \"${appd_cluster_agent_application_name}\"/" ${appd_agent_config_file}
sed -i -e "/^  controllerUrl:/s/^.*$/  controllerUrl: \"http:\/\/${appd_controller_host}:${appd_controller_port}\"/" ${appd_agent_config_file}
sed -i -e "/^  account:/s/^.*$/  account: \"${appd_cluster_agent_account_name}\"/" ${appd_agent_config_file}
sed -i -e "/^  image:/s/^.*$/  image: \"${appd_cluster_agent_docker_image_escaped}\"/" ${appd_agent_config_file}

# configure appdynamics cluster agent for auto instrumentation. ------------------------------------
if [ "$appd_cluster_agent_auto_instrumentation" == "true" ]; then
  echo "To Do: Enable Auto Instrumentation for AppDynamics Cluster Agent supported applications."
fi

# deploy the appdynamics cluster agent. ------------------------------------------------------------
runuser -c "kubectl create -f ${appd_home}/${appd_cluster_agent_home}/cluster-agent.yaml" - ${appd_cluster_agent_user}
runuser -c "kubectl get pods -n appdynamics" - ${appd_cluster_agent_user}

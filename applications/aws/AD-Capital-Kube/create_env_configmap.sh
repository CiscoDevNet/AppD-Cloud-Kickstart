#!/bin/sh
#
# Utility script to retrieve various controller connection details and create the 'env-configmap.yaml' file
# for deployment to an AWS EKS cluster.
#
# export appd_controller_host=34.222.250.100
# export appd_es_api_key=eac2a19f-3038-4e66-887f-12571c1bf156
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

#set -x  # turn command display back ON.

# [MANDATORY] controller host and event service api key.
appd_controller_host="${appd_controller_host:-}"
appd_es_api_key="${appd_es_api_key:-notused}"


# validate mandatory environment variables. --------------------------------------------------

if [ -z "$appd_controller_host" ]; then
  echo "Error: 'appd_controller_host' environment variable not set."
  exit 1
fi

#if [ -z "$appd_es_api_key" ]; then
#  echo "Error: 'appd_es_api_key' environment variable not set."
#  exit 1
#fi

# [OPTIONAL] config parameters [w/ defaults].
appd_controller_appname="${appd_controller_appname:-AD-Capital}"
appd_controller_username="${appd_controller_username:-admin}"
appd_controller_password="${appd_controller_password:-welcome1}"
appd_controller_port="${appd_controller_port:-8090}"
appd_controller_ssl="${appd_controller_ssl:-false}"
appd_controller_account_name="${appd_controller_account_name:-customer1}"
appd_controller_access_key="${appd_controller_access_key:-}"
appd_controller_global_account_name="${appd_controller_global_account_name:-}"
appd_es_port="${appd_es_port:-9080}"
appd_es_ssl="${appd_es_ssl:-false}"


# retrieve account access key and global account name from controller rest api if server is running.
controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

echo "Controller status: ${controller_status}"

 # if server is available, retrieve access key.
if [ "$controller_status" = "true" ] 
then
  # build account info url to retrieve global account name.
  access_key_path="api/accounts/accountinfo?accountname=${appd_controller_account_name}"
  access_key_url="http://${appd_controller_host}:${appd_controller_port}/${access_key_path}"

  # retrieve the account access key from the returned json string.
  controller_credentials="--user root@system:${appd_controller_password}"
  access_key=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,51)}')
  appd_controller_access_key=$(echo ${access_key} | awk -F '"' '/accessKey/ {print $4}')
  echo "Controller access key: ${appd_controller_access_key}"

else
  
  echo "Error: 'appd_controller_access_key' environment variable not set"
  exit 1

fi


# if server is available, retrieve global account name.
if [ "$controller_status" = "true" ] 
then

  # retrieve the global account name from the returned json string.
  controller_credentials="--user root@system:${appd_controller_password}"
  # curl --silent ${controller_credentials} ${access_key_url}
  global_account_name=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"globalAccountName") {print substr($0,RSTART-1,69)}')
  appd_controller_global_account_name=$(echo ${global_account_name} | awk -F '"' '/globalAccountName/ {print $4}')
  echo "Controller global account name: ${appd_controller_global_account_name}"

else

  echo "Error: 'appd_controller_global_account_name' environment variable not set"
  exit 1

fi

# create the env-configmap.yaml file from template
cp ./env-configmap-template.yaml ./env-configmap.yaml
env_config_map=~/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube/env-configmap.yaml

sed -i '/^  APPDYNAMICS_AGENT_APPLICATION_NAME:/c\  APPDYNAMICS_AGENT_APPLICATION_NAME: '${appd_controller_appname} ${env_config_map}
sed -i '/^  APPD_ES_PORT:/c\  APPD_ES_PORT: "'${appd_es_port}'"' ${env_config_map}
sed -i '/^  APPD_ES_SSL:/c\  APPD_ES_SSL: "'${appd_es_ssl}'"' ${env_config_map}
sed -i '/^  APPD_ES_HOST:/c\  APPD_ES_HOST: '${appd_controller_host} ${env_config_map}
sed -i '/^  APPD_EVENT_ACCOUNT_NAME:/c\  APPD_EVENT_ACCOUNT_NAME: '${appd_controller_global_account_name} ${env_config_map}
sed -i '/^  APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY:/c\  APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY: '${appd_controller_access_key} ${env_config_map}
sed -i '/^  APPDYNAMICS_AGENT_ACCOUNT_NAME:/c\  APPDYNAMICS_AGENT_ACCOUNT_NAME: '${appd_controller_account_name} ${env_config_map}
sed -i '/^  APPDYNAMICS_CONTROLLER_HOST_NAME:/c\  APPDYNAMICS_CONTROLLER_HOST_NAME: '${appd_controller_host} ${env_config_map}
sed -i '/^  APPDYNAMICS_CONTROLLER_PORT:/c\  APPDYNAMICS_CONTROLLER_PORT: "'${appd_controller_port}'"' ${env_config_map}
sed -i '/^  APPDYNAMICS_CONTROLLER_SSL_ENABLED:/c\  APPDYNAMICS_CONTROLLER_SSL_ENABLED: "'${appd_controller_ssl}'"' ${env_config_map}
sed -i '/^  APPD_ES_API_KEY:/c\  APPD_ES_API_KEY: "'${appd_es_api_key}'"' ${env_config_map}
sed -i '/^  APPDYNAMICS_CONTROLLER_LOGIN:/c\  APPDYNAMICS_CONTROLLER_LOGIN: "'${appd_controller_username}'@'${appd_controller_account_name}':'${appd_controller_password}'"' ${env_config_map}

mv ./env-configmap.yaml ~/AppD-Cloud-Kickstart/applications/AD-Capital-Kube/Kubernetes/env-configmap.yaml

# create encoded account name and access key for secret.yaml file
cp ./secret-template.yaml ./secret.yaml
secretyaml=~/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube/secret.yaml

appd_encoded_account_name="${appd_encoded_account_name:-}"
appd_encoded_account_name=$(echo -n ${appd_controller_account_name} | base64);
echo "Controller encoded account name: ${appd_encoded_account_name}"

appd_encoded_access_key="${appd_encoded_access_key:-}"
appd_encoded_access_key=$(echo -n ${appd_controller_access_key} | base64);
echo "Controller encoded access key: ${appd_encoded_access_key}"

sed -i '/^  accountname:/c\  accountname: '${appd_encoded_account_name} ${secretyaml}
sed -i '/^  accesskey:/c\  accesskey: '${appd_encoded_access_key} ${secretyaml}

mv ./secret.yaml ~/AppD-Cloud-Kickstart/applications/AD-Capital-Kube/Kubernetes/secret.yaml

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
appd_controller_account_name="${appd_controller_account_name:-customer1}"

appd_controller_access_key="${appd_controller_access_key:-e293d5ac-9496-481f-b668-6e30cdddbb10}"



appd_encoded_account_name="${appd_encoded_account_name:-}"

appd_encoded_account_name=$(echo -n ${appd_controller_account_name} | base64);

echo ${appd_encoded_account_name}


appd_encoded_access_key="${appd_encoded_access_key:-}"

appd_encoded_access_key=$(echo -n ${appd_controller_access_key} | base64);

echo ${appd_encoded_access_key}



ad_cap_kube_deploy_ctr="${ad_cap_kube_deploy_ctr:-Deploying AD-Capital to EKS...}"

## sleep in bash for loop ##
for i in {1..10}
do
  echo ${ad_cap_kube_deploy_ctr}
  ad_cap_kube_deploy_ctr=${ad_cap_kube_deploy_ctr}. 
  sleep 1s
done

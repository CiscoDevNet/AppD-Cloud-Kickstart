#!/bin/sh
# utility script to retrieve the controller access key.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics controller config parameters [w/ defaults].
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
appd_controller_account_name="${appd_controller_account_name:-customer1}"
appd_controller_account_access_key="${appd_controller_account_access_key:-abcdef01-2345-6789-abcd-ef0123456789}"

# retrieve account access key from controller rest api if server is running. -----------------------
controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

# if server is available, retrieve access key.
if [ "$controller_status" == "true" ]; then
  # build account info url to retrieve access key.
  access_key_path="api/accounts/accountinfo?accountname=${appd_controller_account_name}"
  access_key_url="http://${appd_controller_host}:${appd_controller_port}/${access_key_path}"

  # retrieve the account access key from the returned json string.
  controller_credentials="--user root@system:${appd_controller_root_password}"
  access_key=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,length($0)-2)}')
  appd_controller_account_access_key=$(echo ${access_key} | awk -F '"' '/accessKey/ {print $4}')
fi

echo "Account access key: ${appd_controller_account_access_key}"

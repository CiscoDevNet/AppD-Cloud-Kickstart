#!/bin/sh
# utility script to retrieve the controller global account name.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics controller config parameters [w/ defaults].
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
appd_controller_account_name="${appd_controller_account_name:-customer1}"
appd_controller_global_account_name="${appd_controller_global_account_name:-customer1_abcdef01-2345-6789-abcd-ef0123456789}"

# retrieve global account name from controller rest api if server is running. ----------------------
controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

# if server is available, retrieve global account name.
if [ "$controller_status" == "true" ]; then
  # build account info url to retrieve global account name.
  global_account_name_path="api/accounts/accountinfo?accountname=${appd_controller_account_name}"
  global_account_name_url="http://${appd_controller_host}:${appd_controller_port}/${global_account_name_path}"

  # retrieve the global account name from the returned json string.
  controller_credentials="--user root@system:${appd_controller_root_password}"
  global_account_name=$(curl --silent ${controller_credentials} ${global_account_name_url} | awk 'match($0,"globalAccountName") {print substr($0,RSTART-1,length($0)-2)}')
  appd_controller_global_account_name=$(echo ${global_account_name} | awk -F '"' '/globalAccountName/ {print $4}')
fi

echo "Global account name: ${appd_controller_global_account_name}"

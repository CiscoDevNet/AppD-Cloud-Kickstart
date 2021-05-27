#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Java Agent by AppDynamics.
#
# The Java Agent is used to monitor Java applications in the Controller.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Java+Agent
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics account parameters.
set +x  # temporarily turn command display OFF.
appd_username="${appd_username:-}"
appd_password="${appd_password:-}"
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics java agent install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
set +x  # temporarily turn command display OFF.
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_java_agent_home="${appd_java_agent_home:-appagent}"
appd_java_agent_user="${appd_java_agent_user:-centos}"
appd_java_agent_release="${appd_java_agent_release:-21.5.0.32605}"
appd_java_agent_sha256="${appd_java_agent_sha256:-a580d39adef05b402140fb63c0394efc5fefd25677a697c971ae38b5f91570ac}"

# [OPTIONAL] appdynamics java agent config parameters [w/ defaults].
appd_java_agent_config="${appd_java_agent_config:-false}"
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_java_agent_application_name="${appd_java_agent_application_name:-My App}"
appd_java_agent_tier_name="${appd_java_agent_tier_name:-My App Web Tier}"
appd_java_agent_node_name="${appd_java_agent_node_name:-Development}"
appd_java_agent_account_name="${appd_java_agent_account_name:-customer1}"
appd_java_agent_account_access_key="${appd_java_agent_account_access_key:-abcdef01-2345-6789-abcd-ef0123456789}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Java Agent by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] appdynamics account parameters.
    [root]# export appd_username="name@example.com"                     # user name for downloading binaries.
    [root]# export appd_password="password"                             # user password.

  [OPTIONAL] appdynamics java agent install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_controller_root_password="welcome1"             # [optional] controller root password (defaults to 'welcome1').
    [root]# export appd_java_agent_home="appagent"                      # [optional] java agent home (defaults to 'appagent').
    [root]# export appd_java_agent_user="centos"                        # [optional] java agent user (defaults to user 'centos').
    [root]# export appd_java_agent_release="21.5.0.32605"               # [optional] java agent release (defaults to '21.5.0.32605').
                                                                        # [optional] java agent sha-256 checksum (defaults to published value).
    [root]# export appd_java_agent_sha256="a580d39adef05b402140fb63c0394efc5fefd25677a697c971ae38b5f91570ac"

  [OPTIONAL] appdynamics java agent config parameters [w/ defaults].
    [root]# export appd_java_agent_config="true"                        # [optional] configure appd java agent? [boolean] (defaults to 'false').

    NOTE: Setting 'appd_java_agent_config' to 'true' allows you to perform the Java Agent configuration
          concurrently with the installation. When 'true', the following environment variables are used
          for the configuration. To successfully connect to the Controller, you should override the
          'appd_controller_host' and 'appd_controller_port' parameters using valid entries for your
          environment.

          In either case, you will need to validate the configuration before starting the Java Agent. The
          configuration file can be found here: '<java_agent_home>/appagent/ver21.5.0.32605/conf/controller-info.xml'

    [root]# export appd_controller_host="apm"                           # [optional] controller host (defaults to 'apm').
    [root]# export appd_controller_port="8090"                          # [optional] controller port (defaults to '8090').
    [root]# export appd_java_agent_application_name="My App"            # [optional] associate java agent with application (defaults to ''My App).
    [root]# export appd_java_agent_tier_name="My App Web Tier"          # [optional] associate java agent with tier (defaults to 'My App Web Tier').
    [root]# export appd_java_agent_node_name="Development"              # [optional] associate java agent with node (defaults to 'Development').
    [root]# export appd_java_agent_account_name="customer1"             # [optional] account name (defaults to 'customer1').
                                                                        # [optional] account access key (defaults to <placeholder_value>).
    [root]# export appd_java_agent_account_access_key="abcdef01-2345-6789-abcd-ef0123456789"

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

# set appdynamics java agent installation variables. -----------------------------------------------
appd_java_agent_folder="${appd_java_agent_home}-${appd_java_agent_release}"
appd_java_agent_binary="AppServerAgent-1.8-${appd_java_agent_release}.zip"

# create appdynamics java agent parent folder. -----------------------------------------------------
mkdir -p ${appd_home}/${appd_java_agent_folder}
cd ${appd_home}/${appd_java_agent_folder}

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# install appdynamics java agent. ------------------------------------------------------------------
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

# download the appdynamics java agent binary.
rm -f ${appd_java_agent_binary}
curl --silent --location --remote-name --header "Authorization: Bearer ${oauth_token}" https://download.appdynamics.com/download/prox/download-file/java-jdk8/${appd_java_agent_release}/${appd_java_agent_binary}
chmod 644 ${appd_java_agent_binary}

rm -f ${post_data_filename}
rm -f ${oauth_token_filename}

# verify the downloaded binary.
echo "${appd_java_agent_sha256} ${appd_java_agent_binary}" | sha256sum --check
# AppServerAgent-${appd_java_agent_release}.zip: OK

# extract appdynamics java agent binary.
unzip ${appd_java_agent_binary}
rm -f ${appd_java_agent_binary}
cd ${appd_home}
rm -f ${appd_java_agent_home}
ln -s ${appd_java_agent_folder} ${appd_java_agent_home}
chown -R ${appd_java_agent_user}:${appd_java_agent_user} .

# configure appdynamics java agent. ----------------------------------------------------------------
if [ "$appd_java_agent_config" == "true" ]; then
  # set appdynamics java agent configuration variables.
  appd_agent_config_path="${appd_home}/${appd_java_agent_home}/ver${appd_java_agent_release}/conf"
  appd_agent_config_file="controller-info.xml"

  cd ${appd_agent_config_path}

  # save a copy of the current file.
  if [ -f "${appd_agent_config_file}.orig" ]; then
    cp -p ${appd_agent_config_file} ${appd_agent_config_file}.${curdate}
  else
    cp -p ${appd_agent_config_file} ${appd_agent_config_file}.orig
  fi

  # retrieve account access key from controller rest api if server is running.
  controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
  controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

  # if server is available, retrieve access key.
  if [ "$controller_status" == "true" ]; then
    # build account info url to retrieve access key.
    access_key_path="api/accounts/accountinfo?accountname=${appd_java_agent_account_name}"
    access_key_url="http://${appd_controller_host}:${appd_controller_port}/${access_key_path}"

    # retrieve the account access key from the returned json string.
    set +x    # temporarily turn command display OFF.
    controller_credentials="--user root@system:${appd_controller_root_password}"
    access_key_record=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,length($0)-2)}')
    set -x    # turn command display back ON.
    appd_java_agent_account_access_key=$(echo ${access_key_record} | awk -F '"' '/accessKey/ {print $4}')
  fi

  # use the stream editor to substitute the new values.
  sed -i -e "/^    <controller-host>/s/^.*$/    <controller-host>${appd_controller_host}<\/controller-host>/" ${appd_agent_config_file}
  sed -i -e "/^    <controller-port>/s/^.*$/    <controller-port>${appd_controller_port}<\/controller-port>/" ${appd_agent_config_file}
  sed -i -e "/^    <application-name>/s/^.*$/    <application-name>${appd_java_agent_application_name}<\/application-name>/" ${appd_agent_config_file}
  sed -i -e "/^    <tier-name>/s/^.*$/    <tier-name>${appd_java_agent_tier_name}<\/tier-name>/" ${appd_agent_config_file}
  sed -i -e "/^    <node-name>/s/^.*$/    <node-name>${appd_java_agent_node_name}<\/node-name>/" ${appd_agent_config_file}
  sed -i -e "/^    <account-name>/s/^.*$/    <account-name>${appd_java_agent_account_name}<\/account-name>/" ${appd_agent_config_file}
  sed -i -e "/^    <account-access-key>/s/^.*$/    <account-access-key>${appd_java_agent_account_access_key}<\/account-access-key>/" ${appd_agent_config_file}
fi

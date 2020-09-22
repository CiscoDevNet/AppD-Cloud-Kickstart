#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Machine Agent by AppDynamics.
#
# The Standalone Machine Agent (Machine Agent) is used to collect basic hardware metrics and
# is a Java program that has an extensible architecture enabling you to supplement the
# basic metrics reported in the AppDynamics Controller UI with your own custom metrics.
#
# When using this script with Packer for building an immutable VM image, you would use
# cloud-init or Vagrant provisioners to customize the configuration when deploying multiple
# instances created from the image.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Standalone+Machine+Agent
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

# [OPTIONAL] appdynamics machine agent install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
set +x  # temporarily turn command display OFF.
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_machine_agent_home="${appd_machine_agent_home:-machine-agent}"
appd_machine_agent_user="${appd_machine_agent_user:-centos}"
appd_machine_agent_release="${appd_machine_agent_release:-20.9.0.2763}"
appd_machine_agent_sha256="${appd_machine_agent_sha256:-fe642eeb758ed2860fe6429bf215eade0f17c40510a1352eb30618c723d3216f}"

# [OPTIONAL] appdynamics machine agent config parameters [w/ defaults].
appd_machine_agent_config="${appd_machine_agent_config:-false}"
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_machine_agent_controller_ssl_enabled="${appd_machine_agent_controller_ssl_enabled:-false}"
appd_machine_agent_enable_orchestration="${appd_machine_agent_enable_orchestration:-false}"
appd_machine_agent_unique_host_id="${appd_machine_agent_unique_host_id:-}"
appd_machine_agent_sim_enabled="${appd_machine_agent_sim_enabled:-true}"
appd_machine_agent_machine_path="${appd_machine_agent_machine_path:-}"
appd_machine_agent_account_name="${appd_machine_agent_account_name:-customer1}"
appd_machine_agent_account_access_key="${appd_machine_agent_account_access_key:-abcdef01-2345-6789-abcd-ef0123456789}"
appd_machine_agent_java_opts="${appd_machine_agent_java_opts:-}"
appd_machine_agent_application_name="${appd_machine_agent_application_name:-}"
appd_machine_agent_tier_name="${appd_machine_agent_tier_name:-}"
appd_machine_agent_node_name="${appd_machine_agent_node_name:-}"
appd_machine_agent_enable_service="${appd_machine_agent_enable_service:-false}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Machine Agent by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] appdynamics account parameters.
    [root]# export appd_username="name@example.com"                     # user name for downloading binaries.
    [root]# export appd_password="password"                             # user password.

  [OPTIONAL] appdynamics machine agent install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_controller_root_password="welcome1"             # [optional] controller root password (defaults to 'welcome1').
    [root]# export appd_machine_agent_home="machine-agent"              # [optional] machine agent home folder (defaults to 'machine-agent').
    [root]# export appd_machine_agent_user="centos"                     # [optional] machine agent user name (defaults to user 'centos').
    [root]# export appd_machine_agent_release="20.9.0.2763"             # [optional] machine agent release (defaults to '20.9.0.2763').
                                                                        # [optional] machine agent sha-256 checksum (defaults to published value).
    [root]# export appd_machine_agent_sha256="fe642eeb758ed2860fe6429bf215eade0f17c40510a1352eb30618c723d3216f"

  [OPTIONAL] appdynamics machine agent config parameters [w/ defaults].
    [root]# export appd_machine_agent_config="true"                     # [optional] configure appd machine agent? [boolean] (defaults to 'false').

    NOTE: Setting 'appd_machine_agent_config' to 'true' allows you to perform the Machine Agent configuration
          concurrently with the installation. When 'true', the following environment variables are used for
          the configuration. To successfully connect to the Controller, you should override the
          'appd_controller_host' and 'appd_controller_port' parameters using valid entries for your
          environment.

          In either case, you will need to validate the configuration before starting the Machine Agent. The
          configuration file can be found here: '<machine_agent_home>/conf/controller-info.xml'

    [root]# export appd_controller_host="apm"                           # [optional] controller host (defaults to 'apm').
    [root]# export appd_controller_port="8090"                          # [optional] controller port (defaults to '8090').
    [root]# export appd_machine_agent_controller_ssl_enabled="false"    # [optional] controller ssl enabled? [boolean] (defaults to 'false').
    [root]# export appd_machine_agent_enable_orchestration="false"      # [optional] enable orchestration? [boolean] (defaults to 'false').
    [root]# export appd_machine_agent_unique_host_id=""                 # [optional] unique host id (defaults to '').
    [root]# export appd_machine_agent_sim_enabled="true"                # [optional] sim enabled? [boolean] (defaults to 'true').
    [root]# export appd_machine_agent_machine_path=""                   # [optional] machine path (defaults to '').
    [root]# export appd_machine_agent_account_name="customer1"          # [optional] account name (defaults to 'customer1').
                                                                        # [optional] account access key (defaults to <placeholder_value>).
    [root]# export appd_machine_agent_account_access_key="abcdef01-2345-6789-abcd-ef0123456789"
    [root]# export appd_machine_agent_java_opts=""                      # [optional] machine agent java options (defaults to '').
    [root]# export appd_machine_agent_application_name=""               # [optional] associate machine agent with application (defaults to '').
    [root]# export appd_machine_agent_tier_name=""                      # [optional] associate machine agent with tier (defaults to '').
    [root]# export appd_machine_agent_node_name=""                      # [optional] associate machine agent with node (defaults to '').
    [root]# export appd_machine_agent_enable_service="false"            # [optional] enable service to start at boot? [boolean] (defaults to 'false').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate mandatory environment variables. --------------------------------------------------------
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

# if 'application' is set, then all three ('application', 'tier', and 'node') should be set.
if [ -n "$appd_machine_agent_application_name" ]; then
  if [ -z "$appd_machine_agent_tier_name" ]; then
    echo "Error: 'appd_machine_agent_tier_name' environment variable not set."
    echo "       'tier' should be set when 'application' is set."
    usage
    exit 1
  fi

  if [ -z "$appd_machine_agent_node_name" ]; then
    echo "Error: 'appd_machine_agent_node_name' environment variable not set."
    echo "       'node' should be set when 'application' and 'tier' are set."
    usage
    exit 1
  fi
fi

# prepare for appdynamics machine agent installation. ----------------------------------------------
# set machine agent installation variables.
appd_machine_agent_folder="${appd_machine_agent_home}-${appd_machine_agent_release}"
appd_machine_agent_binary="machineagent-bundle-64bit-linux-${appd_machine_agent_release}.zip"

# create machine agent parent folder.
mkdir -p ${appd_home}/${appd_machine_agent_folder}
cd ${appd_home}/${appd_machine_agent_folder}

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# install appdynamics machine agent. ---------------------------------------------------------------
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

# download the machine agent binary.
rm -f ${appd_machine_agent_binary}
curl --silent --location --remote-name --header "Authorization: Bearer ${oauth_token}" https://download.appdynamics.com/download/prox/download-file/machine-bundle/${appd_machine_agent_release}/${appd_machine_agent_binary}
chmod 644 ${appd_machine_agent_binary}

rm -f ${post_data_filename}
rm -f ${oauth_token_filename}

# verify the downloaded binary.
echo "${appd_machine_agent_sha256} ${appd_machine_agent_binary}" | sha256sum --check
# machineagent-bundle-64bit-linux-${appd_machine_agent_release}.zip: OK

# extract machine agent binary.
unzip ${appd_machine_agent_binary}
rm -f ${appd_machine_agent_binary}
cd ${appd_home}
rm -f ${appd_machine_agent_home}
ln -s ${appd_machine_agent_folder} ${appd_machine_agent_home}
chown -R ${appd_machine_agent_user}:${appd_machine_agent_user} .

# configure the appdynamics machine agent as a service. --------------------------------------------
systemd_dir="/etc/systemd/system"
appd_machine_agent_service="appdynamics-machine-agent.service"
service_filepath="${systemd_dir}/${appd_machine_agent_service}"

pid_dir="/var/run/appdynamics"
pid_file="appdynamics-machine-agent.pid"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=AppDynamics Machine Agent" >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "# The machine agent startup script does not fork a process, so this is a simple service." >> "${service_filepath}"
  echo "Type=simple" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "Environment=MACHINE_AGENT_HOME=${appd_home}/${appd_machine_agent_home}" >> "${service_filepath}"
  echo "Environment=JAVA_HOME=${appd_home}/${appd_machine_agent_home}/jre" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "# Specify the 'user' to run the machine agent as." >> "${service_filepath}"
  echo "User=${appd_machine_agent_user}" >> "${service_filepath}"
  echo "Environment=MACHINE_AGENT_USER=${appd_machine_agent_user}" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "Environment=PIDDIR=${pid_dir}" >> "${service_filepath}"
  echo "Environment=PIDFILE=\${PIDDIR}/${pid_file}" >> "${service_filepath}"
  echo "PIDFile=${pid_dir}/${pid_file}" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "# Killing the service using systemd causes Java to exit with status 143. This is OK." >> "${service_filepath}"
  echo "SuccessExitStatus=143" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "# Run ExecStartPre with root-permissions." >> "${service_filepath}"
  echo "PermissionsStartOnly=true" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "ExecStartPre=/usr/bin/install -o \${MACHINE_AGENT_USER} -d \${PIDDIR}" >> "${service_filepath}"

  if [ -z "$appd_machine_agent_java_opts" ]; then
    echo "ExecStart=/bin/sh -c \"\${MACHINE_AGENT_HOME}/bin/machine-agent -p \${PIDFILE} -d\"" >> "${service_filepath}"
  else
    echo "ExecStart=/bin/sh -c \"\${MACHINE_AGENT_HOME}/bin/machine-agent -p \${PIDFILE} -d ${appd_machine_agent_java_opts}\"" >> "${service_filepath}"
  fi

  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

if [ "$appd_machine_agent_enable_service" == "true" ]; then
  # enable the machine agent service to start at boot time.
  systemctl enable "${appd_machine_agent_service}"
  systemctl is-enabled "${appd_machine_agent_service}"

  # check current status.
  #systemctl status "${appd_machine_agent_service}"
fi

# configure appdynamics machine agent. -------------------------------------------------------------
if [ "$appd_machine_agent_config" == "true" ]; then
  # set appdynamics machine agent configuration variables.
  appd_agent_config_path="${appd_home}/${appd_machine_agent_home}/conf"
  appd_agent_config_file="controller-info.xml"

  cd ${appd_agent_config_path}

  # set current date for temporary filename.
  curdate=$(date +"%Y-%m-%d.%H-%M-%S")

  # save a copy of the current file.
  if [ -f "${appd_agent_config_file}.orig" ]; then
    cp -p ${appd_agent_config_file} ${appd_agent_config_file}.${curdate}
  else
    cp -p ${appd_agent_config_file} ${appd_agent_config_file}.orig
  fi

  # retrieve account access key from controller rest api if server is running.
  controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
  controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

  # if server is available, retrieve access key. otherwise, use default <placeholder_value>.
  if [ "$controller_status" == "true" ]; then
    # build account info url to retrieve access key.
    access_key_path="api/accounts/accountinfo?accountname=${appd_machine_agent_account_name}"
    access_key_url="http://${appd_controller_host}:${appd_controller_port}/${access_key_path}"

    # retrieve the account access key from the returned json string.
    set +x    # temporarily turn command display OFF.
    controller_credentials="--user root@system:${appd_controller_root_password}"
    access_key_record=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,length($0)-2)}')
    set -x    # turn command display back ON.
    appd_machine_agent_account_access_key=$(echo ${access_key_record} | awk -F '"' '/accessKey/ {print $4}')
  fi

  # use the stream editor to substitute the new values.
  sed -i -e "/^    <controller-host>/s/^.*$/    <controller-host>${appd_controller_host}<\/controller-host>/" ${appd_agent_config_file}
  sed -i -e "/^    <controller-port>/s/^.*$/    <controller-port>${appd_controller_port}<\/controller-port>/" ${appd_agent_config_file}
  sed -i -e "/^    <controller-ssl-enabled>/s/^.*$/    <controller-ssl-enabled>${appd_machine_agent_controller_ssl_enabled}<\/controller-ssl-enabled>/" ${appd_agent_config_file}
  sed -i -e "/^    <enable-orchestration>/s/^.*$/    <enable-orchestration>${appd_machine_agent_enable_orchestration}<\/enable-orchestration>/" ${appd_agent_config_file}
  sed -i -e "/^    <unique-host-id>/s/^.*$/    <unique-host-id>${appd_machine_agent_unique_host_id}<\/unique-host-id>/" ${appd_agent_config_file}
  sed -i -e "/^    <account-access-key>/s/^.*$/    <account-access-key>${appd_machine_agent_account_access_key}<\/account-access-key>/" ${appd_agent_config_file}
  sed -i -e "/^    <account-name>/s/^.*$/    <account-name>${appd_machine_agent_account_name}<\/account-name>/" ${appd_agent_config_file}
  sed -i -e "/^    <sim-enabled>/s/^.*$/    <sim-enabled>${appd_machine_agent_sim_enabled}<\/sim-enabled>/" ${appd_agent_config_file}
  sed -i -e "/^    <machine-path>/s/^.*$/    <machine-path>${appd_machine_agent_machine_path}<\/machine-path>/" ${appd_agent_config_file}

  # if 'application' is set, then add all three ('application', 'tier', and 'node') to machine agent config.
  if [ -n "$appd_machine_agent_application_name" ]; then
    comment="    <!-- Manually associate Machine Agent with an Application, Tier, and Node. -->"
    application_name="    <application-name>${appd_machine_agent_application_name}<\/application-name>"
    tier_name="    <tier-name>${appd_machine_agent_tier_name}<\/tier-name>"
    node_name="    <node-name>${appd_machine_agent_node_name}<\/node-name>"
    controller_info_end="<\/controller-info>"

    # append prior to '</controller-info>' closing tag.
    sed -i -e "s/${controller_info_end}/${comment}\n${controller_info_end}/g" ${appd_agent_config_file}
    sed -i -e "s/${controller_info_end}/${application_name}\n${controller_info_end}/g" ${appd_agent_config_file}
    sed -i -e "s/${controller_info_end}/${tier_name}\n${controller_info_end}/g" ${appd_agent_config_file}
    sed -i -e "s/${controller_info_end}/${node_name}\n${controller_info_end}/g" ${appd_agent_config_file}
    sed -i -e "s/${controller_info_end}/\n${controller_info_end}/g" ${appd_agent_config_file}
  fi
fi

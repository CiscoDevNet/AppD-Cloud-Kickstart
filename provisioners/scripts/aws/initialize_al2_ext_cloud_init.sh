#!/bin/sh -eux
# appdynamics ext cloud-init script to initialize amazon linux 2 vm imported from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-ext}"

# set appdynamics controller parameters.
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="${appd_controller_port:-8090}"
appd_controller_account_name="${appd_controller_account_name:-customer1}"
set +x  # temporarily turn command display OFF.
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_controller_account_access_key="${appd_controller_account_access_key:-abcdef01-2345-6789-abcd-ef0123456789}"

# override appdynamics java agent config parameters.
appd_java_agent_home="${appd_java_agent_home:-appagent}"
appd_java_agent_release="${appd_java_agent_release:-20.4.0.29862}"

# override appdynamics machine agent config parameters.
appd_machine_agent_home="${appd_machine_agent_home:-machine-agent}"
appd_machine_agent_application_name="${appd_machine_agent_application_name:-}"
appd_machine_agent_tier_name="${appd_machine_agent_tier_name:-}"
appd_machine_agent_tier_component_id="${appd_machine_agent_tier_component_id:-8}"

# override aws ec2 monitoring extension config parameters.
appd_aws_ec2_extension_display_account_name="${appd_aws_ec2_extension_display_account_name:-}"
appd_aws_ec2_extension_aws_regions="${appd_aws_ec2_extension_aws_regions:-us-east-1}"
appd_aws_ec2_extension_cloudwatch_monitoring="${appd_aws_ec2_extension_cloudwatch_monitoring:-Basic}"

# set amazon aws cli credentials (appdynamics).
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# validate mandatory environment variables. --------------------------------------------------------
set +x  # temporarily turn command display OFF.
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: 'AWS_ACCESS_KEY_ID' environment variable not set."
  usage
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: 'AWS_SECRET_ACCESS_KEY' environment variable not set."
  usage
  exit 1
fi
set -x  # turn command display back ON.

# retrieve account access key from controller rest api if server is running. -----------------------
controller_url="http://${appd_controller_host}:${appd_controller_port}/controller/rest/serverstatus"
controller_status=$(curl --silent --connect-timeout 10 ${controller_url} | awk '/available/ {print $0}' | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

# if server is available, retrieve access key. otherwise, use default <placeholder_value>.
if [ "$controller_status" == "true" ]; then
  # build account info url to retrieve access key.
  access_key_path="api/accounts/accountinfo?accountname=${appd_controller_account_name}"
  access_key_url="http://${appd_controller_host}:${appd_controller_port}/${access_key_path}"

  # retrieve the account access key from the returned json string.
  set +x    # temporarily turn command display OFF.
  controller_credentials="--user root@system:${appd_controller_root_password}"
  access_key_record=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,length($0)-2)}')
  set -x    # turn command display back ON.
  appd_controller_account_access_key=$(echo ${access_key_record} | awk -F '"' '/accessKey/ {print $4}')

# # retrieve tier component id.
# if [ -f "/usr/local/bin/jq" ]; then
#   # first, retrieve the application id. ('jq' method.)
#   application_id_path="controller/rest/applications?output=JSON"
#   application_id_url="http://${appd_controller_host}:${appd_controller_port}/${application_id_path}"
#   application_jq_filter=".[] | select(.name | contains(\"${appd_machine_agent_application_name}\")) | {name: .name, id: .id}"
#   application_id=$(curl --silent ${controller_credentials} ${application_id_url} | /usr/local/bin/jq "${application_jq_filter}" | awk '/id/ {print $2}')

#   # next, retrieve the tier id. ('jq' method.)
#   tier_id_path="controller/rest/applications/${application_id}/tiers?output=JSON"
#   tier_id_url="http://${appd_controller_host}:${appd_controller_port}/${tier_id_path}"
#   tier_jq_filter=".[] | select(.name | contains(\"${appd_machine_agent_tier_name}\")) | {name: .name, id: .id}"
#   tier_id=$(curl --silent ${controller_credentials} ${tier_id_url} | /usr/local/bin/jq "${tier_jq_filter}" | awk '/id/ {print $2}')
# fi

# appd_machine_agent_tier_component_id="${tier_id}"
fi

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# configure appdynamics java agent. ----------------------------------------------------------------
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

# use the stream editor to substitute the new values.
sed -i -e "/^    <controller-host>/s/^.*$/    <controller-host>${appd_controller_host}<\/controller-host>/" ${appd_agent_config_file}
sed -i -e "/^    <controller-port>/s/^.*$/    <controller-port>${appd_controller_port}<\/controller-port>/" ${appd_agent_config_file}
sed -i -e "/^    <account-name>/s/^.*$/    <account-name>${appd_controller_account_name}<\/account-name>/" ${appd_agent_config_file}
sed -i -e "/^    <account-access-key>/s/^.*$/    <account-access-key>${appd_controller_account_access_key}<\/account-access-key>/" ${appd_agent_config_file}

# configure appdynamics machine agent. -------------------------------------------------------------
# stop the machine agent service.
appd_machine_agent_service="appdynamics-machine-agent"
systemctl stop "${appd_machine_agent_service}"

# set appdynamics machine agent configuration variables.
appd_agent_config_path="${appd_home}/${appd_machine_agent_home}/conf"
appd_agent_config_file="controller-info.xml"

cd ${appd_agent_config_path}

# save a copy of the current file.
if [ -f "${appd_agent_config_file}.orig" ]; then
  cp -p ${appd_agent_config_file} ${appd_agent_config_file}.${curdate}
else
  cp -p ${appd_agent_config_file} ${appd_agent_config_file}.orig
fi

# use the stream editor to substitute the new values.
sed -i -e "/^    <controller-host>/s/^.*$/    <controller-host>${appd_controller_host}<\/controller-host>/" ${appd_agent_config_file}
sed -i -e "/^    <controller-port>/s/^.*$/    <controller-port>${appd_controller_port}<\/controller-port>/" ${appd_agent_config_file}
sed -i -e "/^    <account-access-key>/s/^.*$/    <account-access-key>${appd_controller_account_access_key}<\/account-access-key>/" ${appd_agent_config_file}
sed -i -e "/^    <account-name>/s/^.*$/    <account-name>${appd_controller_account_name}<\/account-name>/" ${appd_agent_config_file}

# configure aws ec2 monitoring extension. ----------------------------------------------------------
# set appdynamics aws ec2 monitoring extension configuration variables.
appd_aws_ec2_extension_monitors_path="${appd_home}/${appd_machine_agent_home}/monitors"
appd_aws_ec2_extension_folder="AWSEC2Monitor"
appd_aws_ec2_extension_path="${appd_aws_ec2_extension_monitors_path}/${appd_aws_ec2_extension_folder}"
appd_aws_ec2_extension_config_file="config.yml"

cd ${appd_aws_ec2_extension_path}

# save a copy of the current file.
if [ -f "${appd_aws_ec2_extension_config_file}.orig" ]; then
  cp -p ${appd_aws_ec2_extension_config_file} ${appd_aws_ec2_extension_config_file}.${curdate}
else
  cp -p ${appd_aws_ec2_extension_config_file} ${appd_aws_ec2_extension_config_file}.orig
fi

# use the stream editor to substitute the new values.
sed -i -e "/^metricPrefix: \"Server|Component:/s/^.*$/metricPrefix: \"Server|Component:${appd_machine_agent_tier_component_id}|Custom Metrics|Amazon EC2|\"/" ${appd_aws_ec2_extension_config_file}

set +x    # temporarily turn command display OFF.
sed -i -e "/^  - awsAccessKey:/s/^.*$/  - awsAccessKey: \"${AWS_ACCESS_KEY_ID}\"/" ${appd_aws_ec2_extension_config_file}

# escape forward slashes '/' in secret key before substitution.
aws_secret_key_escaped=$(echo ${AWS_SECRET_ACCESS_KEY} | sed 's/\//\\\//g')
sed -i -e "/^    awsSecretKey:/s/^.*$/    awsSecretKey: \"${aws_secret_key_escaped}\"/" ${appd_aws_ec2_extension_config_file}
set -x    # turn command display back ON.

sed -i -e "/^    displayAccountName:/s/^.*$/    displayAccountName: \"${appd_aws_ec2_extension_display_account_name}\"/" ${appd_aws_ec2_extension_config_file}

# format aws regions string before substitution. (replace whitespace separated list with quoted, comma-separated list.)
aws_regions_formatted=$(echo "\"${appd_aws_ec2_extension_aws_regions}\"" | sed 's/ /", "/g')
sed -i -e "/^    regions:/s/^.*$/    regions: \[${aws_regions_formatted}\]/" ${appd_aws_ec2_extension_config_file}

sed -i -e "/^cloudWatchMonitoring:/s/^.*$/cloudWatchMonitoring: \"${appd_aws_ec2_extension_cloudwatch_monitoring}\"/" ${appd_aws_ec2_extension_config_file}

# enable the machine agent service to start at boot time. ------------------------------------------
systemctl enable "${appd_machine_agent_service}"
systemctl is-enabled "${appd_machine_agent_service}"

# start the machine agent service.
systemctl start appdynamics-machine-agent

# check current status.
#systemctl status "${appd_machine_agent_service}"

# add public keys for specificed user. -------------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart-AWS"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBsZpmGJhDGK7OHT7Q5oALQqQaniIiacJgr8EM8rQ6Sv6B2te1G5UTdX45IKFDl54FDrwJ479RDaFRYcvd4QWWzIJ8dhUERESyQRSyb9MXd8R+MDc4iL+2/R23vWLNsFSA01D79Z50Q1ujvDJxzXGY86zJCsRRbkn8ODayUeNJZ5s+f4ACnti6OdjEIZGawZ3Y8ERRb1ZTVG/SbG2KZQxLWQpJSTT4mOB7M/i+RqTl8vB5Gd5j2fQSvLvzhX1sgUvacD6YpIv5YqLPRurnE0Hi/PtcshmJo50/PC0Qypg5q5VJYN5IP5x62iRpnbDBUOe9rpNpp1YqbGXGFQ3TuYPJ AppD-Cloud-Kickstart-AWS"

# 'grep' to see if the user's public is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${aws_ec2_hostname}.localdomain" --static
hostnamectl set-hostname "${aws_ec2_hostname}.localdomain"

# verify configuration.
hostnamectl status

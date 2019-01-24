#!/bin/sh -eux
# appdynamics ext cloud-init script to initialize amazon linux 2 vm imported from ami.

# add public keys for ec2-user user. ---------------------------------------------------------------
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBsZpmGJhDGK7OHT7Q5oALQqQaniIiacJgr8EM8rQ6Sv6B2te1G5UTdX45IKFDl54FDrwJ479RDaFRYcvd4QWWzIJ8dhUERESyQRSyb9MXd8R+MDc4iL+2/R23vWLNsFSA01D79Z50Q1ujvDJxzXGY86zJCsRRbkn8ODayUeNJZ5s+f4ACnti6OdjEIZGawZ3Y8ERRb1ZTVG/SbG2KZQxLWQpJSTT4mOB7M/i+RqTl8vB5Gd5j2fQSvLvzhX1sgUvacD6YpIv5YqLPRurnE0Hi/PtcshmJo50/PC0Qypg5q5VJYN5IP5x62iRpnbDBUOe9rpNpp1YqbGXGFQ3TuYPJ AppD-Cloud-Kickstart-AWS" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeG1qPuiVxXkhlawv3F/PtG2IB3UnGrecCN/0Y4GzIqrNwCcA6MDH5UH1IeBGaCgkm8jXZaOimwkwK4eROSJgJYNtXkYqooVC7SqoIgAbQGKykY9dpgi+ngi9uqALj1l7oUMqAkz6JRO5pueYtoiqo+me8Wbz9Kq6345flqQUh2vDjPfA2xBRGHfUYePQL3nvrc6jX5ad1i8lPuKrp5lXcYUdSP4FBDbEv1zJwi/d6M9irhlptOSGYqQH/zVvZnb1lrYSRv79Gz/WQnce4hKG5GCo5fohbfzlwsqgyFpm6uEu/yjpq/fkPxneNbH1VuljWFsDOjY9xqx8g331cJmbr ADFinancialAWS" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUdqQb2fMOX8XzTtqMORY674lELuv2e01EtkoI6enfmB6dqd7mG/Njcko/kznGoWu/6R7nPQnZ8RGXH+Tq0Z+BfBeuR78dPYyBr0r/tORxCGqIgl1NOOuslp3opl4Hz+ec71MlzoQf/k8rVPpGtSHXeaiKEGBuW9niFVboM1oA+eo3Hmpn10IZK2SQ6LcfHqEPURWr7tJ9HkdJ4K7MRoO/HQ6WC1KJI8b4M8U3jGpbG2CjtI3hZ6s58I+53cHULx00T5xbp3+42A49ldwSAF0NUKjWJMH33KRDt4ZN74C36DkXcLzms28k19DGtsqo/reh4ss3mh57QgHDSoxizB7V EdBarberis" >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys

# set default values for input environment variables if not set. -----------------------------------
appd_home="/opt/appdynamics"
aws_hostname="ext"

# set appdynamics controller parameters.
appd_controller_host="${appd_controller_host:-apm}"
appd_controller_port="8090"
appd_controller_account_name="customer1"
set +x  # temporarily turn command display OFF.
appd_controller_root_password="welcome1"
set -x  # turn command display back ON.
appd_controller_account_access_key="abcdef01-2345-6789-abcd-ef0123456789"

# override appdynamics java agent config parameters.
appd_java_agent_home="appagent"
appd_java_agent_release="4.5.6.24621"

# override appdynamics machine agent config parameters.
appd_machine_agent_home="machine-agent"
appd_machine_agent_application_name="AD-Financial"
appd_machine_agent_tier_name="AWS_Extensions"
appd_machine_agent_tier_component_id="8"

# override aws ec2 monitoring extension config parameters.
appd_aws_ec2_extension_display_account_name="adfin-prd-acct"
appd_aws_ec2_extension_aws_regions="us-east-1 us-east-2 us-west-1 us-west-2"
appd_aws_ec2_extension_cloudwatch_monitoring="Basic"

# set amazon aws cli credentials (appdynamics).
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="AKIAI33ELY7UNTREFZWQ"
AWS_SECRET_ACCESS_KEY="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"
set -x  # turn command display back ON.

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${aws_hostname}.localdomain" --static
hostnamectl set-hostname "${aws_hostname}.localdomain"

# verify configuration.
hostnamectl status

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
  access_key=$(curl --silent ${controller_credentials} ${access_key_url} | awk 'match($0,"accessKey") {print substr($0,RSTART-1,51)}')
  set -x    # turn command display back ON.
  appd_controller_account_access_key=$(echo ${access_key} | awk -F '"' '/accessKey/ {print $4}')

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

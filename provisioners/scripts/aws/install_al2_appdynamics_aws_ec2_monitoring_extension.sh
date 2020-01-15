#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics AWS EC2 monitoring extension from the AppDynamics Community Exchange.
#
# This extension captures statistics for AWS EC2 instances from Amazon CloudWatch and
# displays them in the AppDynamics Metric Browser. To successfully connect to your AWS environment,
# you should set 'AWS_ACCESS_KEY_ID' and 'AWS_SECRET_ACCESS_KEY'.
#
# For more details, please visit:
#   https://www.appdynamics.com/community/exchange/extension/aws-ec2-monitoring-extension/
#
# NOTE: Prior installation of the AppDynamics Machine Agent is required.
#       All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics aws ec2 monitoring extension account parameters.
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics aws ec2 monitoring extension install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
appd_machine_agent_home="${appd_machine_agent_home:-machine-agent}"
appd_machine_agent_user="${appd_machine_agent_user:-centos}"
appd_machine_agent_account_name="${appd_machine_agent_account_name:-customer1}"
appd_aws_ec2_extension_release="${appd_aws_ec2_extension_release:-2.0.1}"
appd_aws_ec2_extension_build="${appd_aws_ec2_extension_build:-1553249199}"

# [OPTIONAL] appdynamics aws ec2 monitoring extension config parameters [w/ defaults].
appd_aws_ec2_extension_config="${appd_aws_ec2_extension_config:-false}"
appd_aws_ec2_extension_display_account_name="${appd_aws_ec2_extension_display_account_name:-}"
appd_aws_ec2_extension_aws_regions="${appd_aws_ec2_extension_aws_regions:-eu-west-3}"
appd_aws_ec2_extension_cloudwatch_monitoring="${appd_aws_ec2_extension_cloudwatch_monitoring:-Basic}"
appd_aws_ec2_extension_tier_component_id="${appd_aws_ec2_extension_tier_component_id:-8}"
appd_machine_agent_application_name="${appd_machine_agent_application_name:-}"
appd_machine_agent_tier_name="${appd_machine_agent_tier_name:-}"
appd_machine_agent_node_name="${appd_machine_agent_node_name:-}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics AWS EC2 monitoring extension from the AppDynamics Community Exchange.

  NOTE: Prior installation of the AppDynamics Machine Agent is required.
        All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] appdynamics aws ec2 monitoring extension account parameters.
    [root]# export AWS_ACCESS_KEY_ID="<your_access_key>"                # aws cli access key id.
    [root]# export AWS_SECRET_ACCESS_KEY="<your_secret_key>"            # aws cli secret access key.

  [OPTIONAL] appdynamics aws ec2 monitoring extension install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_machine_agent_home="machine-agent"              # [optional] machine agent home folder (defaults to 'machine-agent').
    [root]# export appd_machine_agent_user="centos"                     # [optional] machine agent user name (defaults to user 'centos').
    [root]# export appd_machine_agent_account_name="customer1"          # [optional] account name (defaults to 'customer1').
    [root]# export appd_aws_ec2_extension_release="2.0.1"               # [optional] aws ec2 extension release (defaults to user '2.0.1').
    [root]# export appd_aws_ec2_extension_build="1553249199"            # [optional] aws ec2 extension build (defaults to user '1553249199').

  [OPTIONAL] appdynamics aws ec2 monitoring extension config parameters [w/ defaults].
    [root]# export appd_aws_ec2_extension_config="true"                 # [optional] configure aws ec2 extension? [boolean] (defaults to 'false').

    NOTE: Setting 'appd_aws_ec2_extension_config' to 'true' allows you to perform the Monitoring Extension
          configuration concurrently with the installation. When 'true', the following environment variables
          are used for the configuration. To successfully connect to your AWS environment, you should set
          'AWS_ACCESS_KEY_ID' and 'AWS_SECRET_ACCESS_KEY'.

    [root]# export appd_aws_ec2_extension_display_account_name=""       # [optional] account name to display (defaults to '').
    [root]# export appd_aws_ec2_extension_aws_regions="region1 region2" # [optional] whitespace separated list of aws regions to monitor
                                                                        #            (defaults to 'eu-west-3').
    [root]# export appd_aws_ec2_extension_cloudwatch_monitoring="Basic" # [optional] aws cloudwatch monitoring type (defaults to 'Basic').
                                                                        #            valid types:
                                                                        #              'Basic', 'Detailed'
    [root]# export appd_aws_ec2_extension_tier_component_id="8"         # [optional] tier component id for aws metric prefix (defaults to '8').
    [root]# export appd_machine_agent_application_name=""               # [optional] associate machine agent with application (defaults to '').
    [root]# export appd_machine_agent_tier_name=""                      # [optional] associate machine agent with tier (defaults to '').
    [root]# export appd_machine_agent_node_name=""                      # [optional] associate machine agent with node (defaults to '').

  --------
  Example:
  --------
    [root]# $0
EOF
}

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

if [ -n "$appd_aws_ec2_extension_cloudwatch_monitoring" ]; then
  case $appd_aws_ec2_extension_cloudwatch_monitoring in
      Basic|Detailed)
        ;;
      *)
        echo "Error: invalid 'appd_aws_ec2_extension_cloudwatch_monitoring' type: Must be 'Basic' or 'Detailed'."
        usage
        exit 1
        ;;
  esac
fi

# set appdynamics aws ec2 monitoring extension installation variables. -----------------------------
appd_aws_ec2_extension_monitors_path="${appd_home}/${appd_machine_agent_home}/monitors"
appd_aws_ec2_extension_folder="AWSEC2Monitor"
appd_aws_ec2_extension_binary="awsec2monitor-${appd_aws_ec2_extension_release}.zip"

# install appdynamics aws ec2 monitoring extension. ------------------------------------------------
# validate that machine agent 'monitors' folder exists.
if [ ! -d "${appd_aws_ec2_extension_monitors_path}" ]; then
  echo "Error: '${appd_aws_ec2_extension_monitors_path}' machine agent monitors folder does not exist."
  exit 1
fi

# change directory to the machine agent 'monitors' folder.
cd ${appd_aws_ec2_extension_monitors_path}

# download the appdynamics aws ec2 monitoring extension binary.
rm -f ${appd_aws_ec2_extension_binary}
curl --silent --location --remote-name https://www.appdynamics.com/media/uploaded-files/${appd_aws_ec2_extension_build}/${appd_aws_ec2_extension_binary}
chmod 644 ${appd_aws_ec2_extension_binary}

# extract appdynamics aws ec2 monitoring extension binary.
unzip ${appd_aws_ec2_extension_binary}
rm -f ${appd_aws_ec2_extension_binary}
chown -R ${appd_machine_agent_user}:${appd_machine_agent_user} .
cd ${appd_aws_ec2_extension_folder}

# configure appdynamics aws ec2 monitoring extension. ----------------------------------------------
if [ "$appd_aws_ec2_extension_config" == "true" ]; then
  # set appdynamics aws ec2 monitoring extension configuration variables.
  appd_aws_ec2_extension_monitors_path="${appd_home}/${appd_machine_agent_home}/monitors"
  appd_aws_ec2_extension_folder="AWSEC2Monitor"
  appd_aws_ec2_extension_path="${appd_aws_ec2_extension_monitors_path}/${appd_aws_ec2_extension_folder}"
  appd_aws_ec2_extension_config_file="config.yml"

  cd ${appd_aws_ec2_extension_path}

  # set current date for temporary filename.
  curdate=$(date +"%Y-%m-%d.%H-%M-%S")

  # save a copy of the current file.
  if [ -f "${appd_aws_ec2_extension_config_file}.orig" ]; then
    cp -p ${appd_aws_ec2_extension_config_file} ${appd_aws_ec2_extension_config_file}.${curdate}
  else
    cp -p ${appd_aws_ec2_extension_config_file} ${appd_aws_ec2_extension_config_file}.orig
  fi

  # use the stream editor to substitute the new values.
  sed -i -e "/^metricPrefix: \"Server|Component:/s/^.*$/metricPrefix: \"Server|Component:${appd_aws_ec2_extension_tier_component_id}|Custom Metrics|Amazon EC2|\"/" ${appd_aws_ec2_extension_config_file}

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

  # add 'eu-west-2' and 'eu-west-3' as a region endpoints. (it is curently missing in release 2.0.1.)
  eu_west_1="  eu-west-1: monitoring.eu-west-1.amazonaws.com"           # Europe (Ireland)
  eu_west_2="  eu-west-2: monitoring.eu-west-2.amazonaws.com"           # Europe (London)
  eu_west_3="  eu-west-3: monitoring.eu-west-3.amazonaws.com"           # Europe (Paris)
  match=$(awk 'BEGIN{found="false"} {if (/monitoring.eu-west-2/) found="true"} END {print found}' ${appd_aws_ec2_extension_config_file})

  # if 'eu-west-2' region endpoint not found, add it underneath 'eu-west-1'.
  if [ "$match" == "false" ]; then
    sed -i -e "/^${eu_west_1}/s/^.*$/${eu_west_1}\n${eu_west_2}/" ${appd_aws_ec2_extension_config_file}
  fi

  match=$(awk 'BEGIN{found="false"} {if (/monitoring.eu-west-3/) found="true"} END {print found}' ${appd_aws_ec2_extension_config_file})

  # if 'eu-west-3' region endpoint not found, add it underneath 'eu-west-2'.
  if [ "$match" == "false" ]; then
    sed -i -e "/^${eu_west_2}/s/^.*$/${eu_west_2}\n${eu_west_3}/" ${appd_aws_ec2_extension_config_file}
  fi

  # add 'us-east-2' as a region endpoint. (it is curently missing in release 2.0.1.)
  us_east_1="  us-east-1: monitoring.us-east-1.amazonaws.com"           # US East (N. Virinia)
  us_east_2="  us-east-2: monitoring.us-east-2.amazonaws.com"           # US East (Ohio)
  match=$(awk 'BEGIN{found="false"} {if (/monitoring.us-east-2/) found="true"} END {print found}' ${appd_aws_ec2_extension_config_file})

  # if 'us-east-2' region endpoint not found, add it underneath 'us-east-1'.
  if [ "$match" == "false" ]; then
    sed -i -e "/^${us_east_1}/s/^.*$/${us_east_1}\n${us_east_2}/" ${appd_aws_ec2_extension_config_file}
  fi

  # To-Do's
  #ca-central-1="  ca-central-1: monitoring.ca-central-1.amazonaws.com" # Canada (Central)
  #eu-north-1="  eu-north-1: monitoring.eu-north-1.amazonaws.com"       # EU (Stockholm)
fi

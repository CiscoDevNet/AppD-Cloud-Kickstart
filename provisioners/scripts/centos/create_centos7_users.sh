#!/bin/sh -eux
# create new users on centos linux 7.x.

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# set empty default values for user env variables if not set. --------------------------------------
user_names="${user_names:-}"
user_ids="${user_ids:-}"
set +x  # temporarily turn command display OFF.
user_password="${user_password:-welcome1}"
set -x  # turn command display back ON.
user_group="${user_group:-centos}"
user_supplementary_groups="${user_supplementary_groups:-adm,docker,systemd-journal,wheel}"
user_sudo_privileges="${user_sudo_privileges:-true}"
user_install_env="${user_install_env:-true}"
user_docker_profile="${user_docker_profile:-true}"
user_prompt_color="${user_prompt_color:-green}"

aws_cli_user_config="${aws_cli_user_config:-true}"
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_names="user1 user2 user3"           # whitespace separated list of user names.
    [root]# export user_ids="101 102 103"                   # [optional] whitespace separated list of user ids.
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$user_names" ]; then
  echo "Error: 'user_names' environment variable not set."
  usage
  exit 1
fi

set +x    # temporarily turn command display OFF.
if [ -z "$user_password" ]; then
  echo "Error: 'user_password' environment variable not set."
  usage
  exit 1
fi
set -x    # turn command display back ON.

if [ -z "$user_group" ]; then
  echo "Error: 'user_group' environment variable not set."
  usage
  exit 1
fi

if [ -n "$user_prompt_color" ]; then
  case $user_prompt_color in
      black|blue|cyan|green|magenta|red|white|yellow)
        ;;
      *)
        echo "Error: invalid 'user_prompt_color'."
        usage
        exit 1
        ;;
  esac
fi

if [ "$aws_cli_user_config" == "true" ]; then
  set +x    # temporarily turn command display OFF.
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
  set -x    # turn command display back ON.

  if [ -n "$aws_cli_default_output_format" ]; then
    case $aws_cli_default_output_format in
        json|text|table)
          ;;
        *)
          echo "Error: invalid 'aws_cli_default_output_format'."
          usage
          exit 1
          ;;
    esac
  fi
fi

# initialize user name and id arrays. --------------------------------------------------------------
user_names_array=( $user_names )
user_names_length=${#user_names_array[@]}
user_ids_array=( $user_ids )
user_ids_length=${#user_ids_array[@]}

# if user ids are present, do the number of user names and ids match?
if [ -n "$user_ids" ]; then
  if [ ! "$user_names_length" -eq "$user_ids_length" ];then
    echo "Error: Number of 'user_names' and 'user_ids' must be equal."
    usage
    exit 1
  fi
fi

# export user environment variables. ---------------------------------------------------------------
export user_password
export user_group
export user_supplementary_groups
export user_sudo_privileges
export user_install_env
export user_docker_profile
export user_prompt_color

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export aws_cli_default_region_name
export aws_cli_default_output_format

# loop to create each user. ------------------------------------------------------------------------
ii=0                                                        # initialize array index.
for user_name in "${user_names_array[@]}"; do
  export user_name

  # check for custom user ids.
  if [ -n "$user_ids" ]; then
    export user_id="${user_ids_array[$ii]}"
  else
    unset user_id
  fi

  cd ${kickstart_home}/provisioners/scripts/centos
  ./create_centos7_user.sh

  cd ${kickstart_home}/provisioners/scripts/common

  if [ "$aws_cli_user_config" == "true" ]; then
    ./config_aws_cli_2.sh
  fi

  ./install_nodejs_javascript_runtime.sh
  ./install_serverless_framework_cli.sh
  ./install_appdynamics_nodejs_serverless_tracer.sh

  ii=$(($ii + 1))                                           # increment array index.
done

# unset user environment variables. ----------------------------------------------------------------
unset user_name
unset user_id

unset user_password
unset user_group
unset user_supplementary_groups
unset user_sudo_privileges
unset user_install_env
unset user_docker_profile
unset user_prompt_color

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset aws_cli_default_region_name
unset aws_cli_default_output_format

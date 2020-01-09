#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AWS Command Line Interface (CLI) by Amazon.
#
# The AWS Command Line Interface (CLI) is a unified tool to manage your AWS services. With
# just one tool to download and configure, you can control multiple AWS services from the
# command line and automate them through scripts.
#
# The AWS CLI also introduces a new set of simple file commands for efficient file transfers
# to and from Amazon S3.
#
# For more details, please visit:
#   https://aws.amazon.com/cli/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws cli install parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_cli_user_config="${aws_cli_user_config:-false}"
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
  Install AWS Command Line Interface (CLI) by Amazon.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] aws cli install parameters [w/ defaults].
    [root]# export user_name="centos"                           # [optional] user name (defaults to 'centos').
    [root]# export aws_cli_user_config="true"                   # [optional] configure aws cli for user? [boolean] (defaults to 'false').

    NOTE: Setting 'aws_cli_user_config' to 'true' allows you to perform the AWS CLI configuration concurrently
          with the installation. When 'true', the following environment variables are used for the
          configuration. To successfully connect to your AWS environment, you should set 'AWS_ACCESS_KEY_ID'
          and 'AWS_SECRET_ACCESS_KEY'.

    [root]# export AWS_ACCESS_KEY_ID="<YourKeyID>"              # aws access key id.
    [root]# export AWS_SECRET_ACCESS_KEY="<YourSecretKey>"      # aws secret access key.
    [root]# export aws_cli_default_region_name="us-east-1"      # [optional] aws cli default region name (defaults to 'us-east-1' [N. Virginia]).
    [root]# export aws_cli_default_output_format="json"         # [optional] aws cli default output format (defaults to 'json').
                                                                #            valid output formats:
                                                                #              'json', 'text', 'table'
  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
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

# verify pip installation. -------------------------------------------------------------------------
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 --version" - ${user_name}

# install aws cli. ---------------------------------------------------------------------------------
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install awscli --upgrade --user" - ${user_name}

# verify installation.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws --version" - ${user_name}

# configure the aws cli client. --------------------------------------------------------------------
if [ "$aws_cli_user_config" == "true" ]; then
  set +x    # temporarily turn command display OFF.
  aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
  set -x    # turn command display back ON.

  # verify the aws cli configuration by displaying a list of aws regions in table format.
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}
fi

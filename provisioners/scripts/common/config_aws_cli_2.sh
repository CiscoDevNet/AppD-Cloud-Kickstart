#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Configure the AWS Command Line Interface (CLI) 2 by Amazon for the specified user.
#
# The AWS Command Line Interface (AWS CLI) 2 is an open source tool that enables you to interact
# with AWS services using commands in your command-line shell. AWS CLI version 2 is the most
# recent major version of the AWS CLI and supports all of the latest features. Some features
# introduced in version 2 are not backward compatible with version 1 and you must upgrade to
# access those features.
#
# For more details, please visit:
#   https://aws.amazon.com/cli/
#   https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux-mac.html
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws cli 2 install parameters [w/ defaults].
user_name="${user_name:-centos}"
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
  Configure the AWS Command Line Interface (CLI) 2 by Amazon for the specified user.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] aws cli 2 install parameters [w/ defaults].
    [root]# export user_name="centos"                           # [optional] user name (defaults to 'centos').

    NOTE: The following environment variables are used for the configuration. To successfully connect
          to your AWS environment, you should set 'AWS_ACCESS_KEY_ID' and 'AWS_SECRET_ACCESS_KEY'.

    [root]# export AWS_ACCESS_KEY_ID="<YourKeyID>"              # aws access key id.
    [root]# export AWS_SECRET_ACCESS_KEY="<YourSecretKey>"      # aws secret access key.
    [root]# export aws_cli_default_region_name="us-east-1"      # [optional] aws cli 2 default region name (defaults to 'us-east-1' [N. Virginia]).
    [root]# export aws_cli_default_output_format="json"         # [optional] aws cli 2 default output format (defaults to 'json').
                                                                #            valid output formats:
                                                                #              'json', 'text', 'table'
  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
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

# verify installation. -----------------------------------------------------------------------------
# set aws cli 2 environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify aws cli 2 version.
aws --version

# configure the aws 2 cli client. ------------------------------------------------------------------
aws_cli_executable="/usr/local/bin/aws"

if [ -f "$aws_cli_executable" ]; then
  set +x    # temporarily turn command display OFF.
  aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
  set -x    # turn command display back ON.

  # verify the aws cli 2 configuration by displaying the caller identity.
# runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws sts get-caller-identity" - ${user_name}

  # verify the aws cli 2 configuration by displaying a list of aws regions in table format.
  runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}
fi

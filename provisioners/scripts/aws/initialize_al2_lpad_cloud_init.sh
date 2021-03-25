#!/bin/sh -eux
# appdynamics lpad cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] aws cli config parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-lpad}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# validate environment variables. ------------------------------------------------------------------
set +x    # temporarily turn command display OFF.
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: 'AWS_ACCESS_KEY_ID' environment variable not set."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: 'AWS_SECRET_ACCESS_KEY' environment variable not set."
  exit 1
fi
set -x    # turn command display back ON.

if [ -n "$aws_cli_default_output_format" ]; then
  case $aws_cli_default_output_format in
      json|text|table)
        ;;
      *)
        echo "Error: invalid 'aws_cli_default_output_format'."
        exit 1
        ;;
  esac
fi

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEyVAKfQ/Oq2Cov6ZiGfEI3N2Rz3QG1oVQbz9mYZZMYoDpt67nov+wVDUuham7MG30jgQwMoyGSVUP0ol2R+IDyg+dzSS/XEByrA7IUlLLcYZY8d8VqJOKzoqImfSpTfE0ObbkuYiR1RgOCnQkaH3oHOHpQtse5YxTFdohOaEFlvkAAVe4kSU4/FrxcO1+AL+5CFbl0FqffvqdwNABYd+dNKXylO6rhrMz/v/xAltH2gycj0Xc7c5IGPAqhR08Ei4Q/rTNQeARrUAvkH+LwWP73lAzJNnvgDiGmUegA8ZnlMhvK1dSUftZ72HhO1lG05Q2Rm4U1F0wG+a0fm352Aif AppD-Cloud-Kickstart"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh

# configure the aws cli client. --------------------------------------------------------------------
# remove current configuration if it exists.
aws_cli_config_dir="/home/${user_name}/.aws"
if [ -d "$aws_cli_config_dir" ]; then
  rm -Rf ${aws_cli_config_dir}
fi

set +x    # temporarily turn command display OFF.
aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
set -x    # turn command display back ON.

# verify the aws cli configuration by displaying a list of aws regions in table format.
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}

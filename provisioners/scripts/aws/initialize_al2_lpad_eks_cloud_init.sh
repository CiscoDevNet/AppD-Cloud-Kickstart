#!/bin/sh -eux
# appdynamics lpad cloud-init script to initialize amazon linux 2 vm imported from ami.

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] aws cli config parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-west-2}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-lpad}"

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

#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-terraform-user}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart-AWS"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBsZpmGJhDGK7OHT7Q5oALQqQaniIiacJgr8EM8rQ6Sv6B2te1G5UTdX45IKFDl54FDrwJ479RDaFRYcvd4QWWzIJ8dhUERESyQRSyb9MXd8R+MDc4iL+2/R23vWLNsFSA01D79Z50Q1ujvDJxzXGY86zJCsRRbkn8ODayUeNJZ5s+f4ACnti6OdjEIZGawZ3Y8ERRb1ZTVG/SbG2KZQxLWQpJSTT4mOB7M/i+RqTl8vB5Gd5j2fQSvLvzhX1sgUvacD6YpIv5YqLPRurnE0Hi/PtcshmJo50/PC0Qypg5q5VJYN5IP5x62iRpnbDBUOe9rpNpp1YqbGXGFQ3TuYPJ AppD-Cloud-Kickstart-AWS"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# retrieve the lab user index from the ec2 instance name tag.
aws_ec2_instance_id="$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"
aws_cli_cmd="aws ec2 describe-tags --filters \"Name=resource-id,Values=${aws_ec2_instance_id}\" \"Name=key,Values=Name\" --region ${aws_cli_default_region_name} | jq -r '.Tags[0].Value'"
aws_ec2_name_tag=$(runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} eval ${aws_cli_cmd}" - ${user_name})
aws_ec2_lab_user_index=$(runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} eval ${aws_cli_cmd}" - ${user_name} | awk -F "-" '{print $NF}')
aws_ec2_lab_hostname=$(printf "${aws_ec2_hostname}-%02d\n" "${aws_ec2_lab_user_index}")
aws_ec2_hostname=${aws_ec2_lab_hostname}

# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh

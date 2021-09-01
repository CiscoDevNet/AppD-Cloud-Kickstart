#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-terraform-user}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"
use_aws_ec2_num_suffix="${use_aws_ec2_num_suffix:-true}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEyVAKfQ/Oq2Cov6ZiGfEI3N2Rz3QG1oVQbz9mYZZMYoDpt67nov+wVDUuham7MG30jgQwMoyGSVUP0ol2R+IDyg+dzSS/XEByrA7IUlLLcYZY8d8VqJOKzoqImfSpTfE0ObbkuYiR1RgOCnQkaH3oHOHpQtse5YxTFdohOaEFlvkAAVe4kSU4/FrxcO1+AL+5CFbl0FqffvqdwNABYd+dNKXylO6rhrMz/v/xAltH2gycj0Xc7c5IGPAqhR08Ei4Q/rTNQeARrUAvkH+LwWP73lAzJNnvgDiGmUegA8ZnlMhvK1dSUftZ72HhO1lG05Q2Rm4U1F0wG+a0fm352Aif AppD-Cloud-Kickstart"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh

#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize gcp compute engine instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] gcp user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
gcp_gce_hostname="${gcp_gce_hostname:-terraform-user}"
gcp_gce_domain="${gcp_gce_domain:-localdomain}"
use_gcp_gce_num_suffix="${use_gcp_gce_num_suffix:-true}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart-AWS"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBsZpmGJhDGK7OHT7Q5oALQqQaniIiacJgr8EM8rQ6Sv6B2te1G5UTdX45IKFDl54FDrwJ479RDaFRYcvd4QWWzIJ8dhUERESyQRSyb9MXd8R+MDc4iL+2/R23vWLNsFSA01D79Z50Q1ujvDJxzXGY86zJCsRRbkn8ODayUeNJZ5s+f4ACnti6OdjEIZGawZ3Y8ERRb1ZTVG/SbG2KZQxLWQpJSTT4mOB7M/i+RqTl8vB5Gd5j2fQSvLvzhX1sgUvacD6YpIv5YqLPRurnE0Hi/PtcshmJo50/PC0Qypg5q5VJYN5IP5x62iRpnbDBUOe9rpNpp1YqbGXGFQ3TuYPJ AppD-Cloud-Kickstart-AWS"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the gcp gce instance. --------------------------------------------------
# export environment variables.
export gcp_gce_hostname
export gcp_gce_domain

# set the hostname.
./config_gcp_system_hostname.sh

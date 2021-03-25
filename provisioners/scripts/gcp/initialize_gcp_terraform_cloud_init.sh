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

# define gcp gke monitoring lab user variables. ----------------------------------------------------
# retrieve the name attribute from the gce vm instance metadata.
gcp_gce_instance_name=$(curl --silent -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")

# if num suffix is present, retrieve the value.
if [ "$use_gcp_gce_num_suffix" == "true" ]; then
  gcp_gce_instance_count=$(echo ${gcp_gce_instance_name} | awk -F "-" '{print $2}')
else
  gcp_gce_instance_count=""
fi

# if date is present, split the instance name into separate hostname and date variables.
if [ $(echo "$gcp_gce_instance_name" | grep '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$') ]; then
  gcp_gce_hostname="${gcp_gce_instance_name:0:-11}"
  gcp_gce_instance_date="${gcp_gce_instance_name: -10}"
else
  gcp_gce_hostname="${gcp_gce_instance_name}"
  gcp_gce_instance_date=""
fi

# set the gke cluster name.
if [ ! -z "$gcp_gce_instance_date" ]; then
  gcp_gke_cluster_name="lab${gcp_gce_instance_count}-gke-${gcp_gce_instance_date}"
else
  gcp_gke_cluster_name="lab${gcp_gce_instance_count}-gke"
fi

# use the stream editor to substitute new values into the user bash config. ------------------------
bashrc_config_file="${user_home}/.bashrc"
cp -p ${bashrc_config_file} ${bashrc_config_file}.orig

# define stream editor search strings.
bashrc_search="# define prompt code and colors."

# define stream editor gcp gke monitoring lab config substitution strings.
lab_config_line_01="# define gcp gke monitoring lab environment variables."
lab_config_line_02="gcp_gke_cluster_name=${gcp_gke_cluster_name}"
lab_config_line_03="export gcp_gke_cluster_name"
lab_config_line_04="#appd_controller_host=apm"
lab_config_line_05="#export appd_controller_host"
lab_config_line_06="appd_install_kubernetes_metrics_server=false"
lab_config_line_07="export appd_install_kubernetes_metrics_server"
lab_config_line_08="appd_cluster_agent_auto_instrumentation=false"
lab_config_line_09="export appd_cluster_agent_auto_instrumentation"
lab_config_line_10="#appd_cluster_agent_account_access_key=abcdef01-2345-6789-abcd-ef0123456789"
lab_config_line_11="#export appd_cluster_agent_account_access_key"
lab_config_line_12="appd_cluster_agent_docker_image=edbarberis\/cluster-agent:latest"
lab_config_line_13="export appd_cluster_agent_docker_image"
lab_config_line_14="appd_cluster_agent_application_name=AD-Capital"
lab_config_line_15="export appd_cluster_agent_application_name"
lab_config_line_16=""

# insert lab config lines before this comment: '# define prompt code and colors.'
sed -i -e "s/${bashrc_search}/${lab_config_line_01}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_02}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_03}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_04}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_05}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_06}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_07}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_08}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_09}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_10}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_11}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_12}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_13}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_14}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_15}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_16}\n${bashrc_search}/g" ${bashrc_config_file}

# export environment variables.
export gcp_gce_hostname
export gcp_gce_domain

# set the hostname.
./config_gcp_system_hostname.sh

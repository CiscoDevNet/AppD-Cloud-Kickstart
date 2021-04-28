#!/bin/sh -eux
# appdynamics azure aks monitoring lab cloud-init script to initialize azure vm instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] azure user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
azurerm_vm_hostname="${azurerm_vm_hostname:-terraform-host}"
azurerm_vm_domain="${azurerm_vm_domain:-localdomain}"
use_azurerm_vm_num_suffix="${use_azurerm_vm_num_suffix:-true}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEyVAKfQ/Oq2Cov6ZiGfEI3N2Rz3QG1oVQbz9mYZZMYoDpt67nov+wVDUuham7MG30jgQwMoyGSVUP0ol2R+IDyg+dzSS/XEByrA7IUlLLcYZY8d8VqJOKzoqImfSpTfE0ObbkuYiR1RgOCnQkaH3oHOHpQtse5YxTFdohOaEFlvkAAVe4kSU4/FrxcO1+AL+5CFbl0FqffvqdwNABYd+dNKXylO6rhrMz/v/xAltH2gycj0Xc7c5IGPAqhR08Ei4Q/rTNQeARrUAvkH+LwWP73lAzJNnvgDiGmUegA8ZnlMhvK1dSUftZ72HhO1lG05Q2Rm4U1F0wG+a0fm352Aif AppD-Cloud-Kickstart"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the image build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# define azure aks monitoring lab user variables. --------------------------------------------------
# retrieve the name attribute from the azure vm instance metadata.
azurerm_vm_instance_name=$(curl --silent -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" | jq -r '. | {name: .compute.name} | .[] | values')

# if num suffix is present, retrieve the value.
if [ "$use_azurerm_vm_num_suffix" == "true" ]; then
  azurerm_vm_instance_count=$(echo ${azurerm_vm_instance_name} | awk -F "-" '{print $(NF-4)}')
else
  azurerm_vm_instance_count=""
fi

# if date is present, split the date string into a separate variable.
if [ $(echo "$azurerm_vm_instance_name" | grep '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$') ]; then
  azurerm_vm_instance_date="${azurerm_vm_instance_name: -10}"
else
  azurerm_vm_instance_date=""
fi

# set the aks cluster name.
if [ ! -z "$azurerm_vm_instance_date" ]; then
  azurerm_aks_cluster_name="aks-${azurerm_vm_instance_count}-cluster-${azurerm_vm_instance_date}"
else
  azurerm_aks_cluster_name="aks-${azurerm_vm_instance_count}-cluster"
fi

# retrieve the computer name (hostname) attribute from the azure vm instance metadata.
azurerm_vm_hostname=$(curl --silent -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" | jq -r '. | {name: .compute.osProfile.computerName} | .[] | values')

# retrieve the resource group name attribute from the azure vm instance metadata.
azurerm_resource_group=$(curl --silent -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" | jq -r '. | {resourceGroupName: .compute.resourceGroupName} | .[] | values')

# use the stream editor to substitute new values into the user bash config. ------------------------
bashrc_config_file="${user_home}/.bashrc"
cp -p ${bashrc_config_file} ${bashrc_config_file}.orig

# define stream editor search strings.
bashrc_search="# define prompt code and colors."

# define stream editor azure aks monitoring lab config substitution strings.
lab_config_line_01="# define azure aks monitoring lab environment variables."
lab_config_line_02="azurerm_aks_cluster_name=${azurerm_aks_cluster_name}"
lab_config_line_03="export azurerm_aks_cluster_name"
lab_config_line_04="azurerm_resource_group=${azurerm_resource_group}"
lab_config_line_05="export azurerm_resource_group"
lab_config_line_06="#appd_controller_host=apm"
lab_config_line_07="#export appd_controller_host"
lab_config_line_08="appd_install_kubernetes_metrics_server=false"
lab_config_line_09="export appd_install_kubernetes_metrics_server"
lab_config_line_10="appd_cluster_agent_auto_instrumentation=false"
lab_config_line_11="export appd_cluster_agent_auto_instrumentation"
lab_config_line_12="#appd_cluster_agent_account_access_key=abcdef01-2345-6789-abcd-ef0123456789"
lab_config_line_13="#export appd_cluster_agent_account_access_key"
lab_config_line_14="appd_cluster_agent_docker_image=edbarberis\/cluster-agent:latest"
lab_config_line_15="export appd_cluster_agent_docker_image"
lab_config_line_16="appd_cluster_agent_application_name=AD-Capital"
lab_config_line_17="export appd_cluster_agent_application_name"
lab_config_line_18=""

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
sed -i -e "s/${bashrc_search}/${lab_config_line_17}\n${bashrc_search}/g" ${bashrc_config_file}
sed -i -e "s/${bashrc_search}/${lab_config_line_18}\n${bashrc_search}/g" ${bashrc_config_file}

# export environment variables.
export azurerm_vm_hostname
export azurerm_vm_domain

# set the hostname.
./config_azure_vm_instance_hostname.sh

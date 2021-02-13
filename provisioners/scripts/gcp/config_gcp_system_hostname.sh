#!/bin/sh -eux
# configure the hostname of a gcp compute engine instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] gcp gce hostname config parameters [w/ defaults].
gcp_gce_hostname="${gcp_gce_hostname:-apm}"
gcp_gce_domain="${gcp_gce_domain:-localdomain}"

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${gcp_gce_hostname}.${gcp_gce_domain}" --static
hostnamectl set-hostname "${gcp_gce_hostname}.${gcp_gce_domain}"

# verify configuration.
hostnamectl status

# modify system network configuration. -------------------------------------------------------------
network_config_file="/etc/sysconfig/network"

if [ -f "$network_config_file" ]; then
  cp -p $network_config_file ${network_config_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c '^HOSTNAME' "$network_config_file") -eq 0 ]; then
    echo "HOSTNAME=${gcp_gce_hostname}.${gcp_gce_domain}" >> ${network_config_file}
  else
    sed -i -e "/^HOSTNAME/s/^.*$/HOSTNAME=${gcp_gce_hostname}.${gcp_gce_domain}/" ${network_config_file}
  fi

  # verify configuration.
  grep '^HOSTNAME' "$network_config_file"
fi

# modify system hosts file. ------------------------------------------------------------------------
system_hosts_file="/etc/hosts"

if [ -f "$system_hosts_file" ]; then
  cp -p $system_hosts_file ${system_hosts_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c "${gcp_gce_hostname}" "$system_hosts_file") -eq 0 ]; then
    sed -i -e "1i\127.0.0.1   ${gcp_gce_hostname}.${gcp_gce_domain} ${gcp_gce_hostname}" ${system_hosts_file}
  else
    sed -i -e "/${gcp_gce_hostname}/s/^.*$/127.0.0.1   ${gcp_gce_hostname}.${gcp_gce_domain} ${gcp_gce_hostname}/" ${system_hosts_file}
  fi

  # verify configuration.
  grep "$gcp_gce_hostname" "$system_hosts_file"
fi

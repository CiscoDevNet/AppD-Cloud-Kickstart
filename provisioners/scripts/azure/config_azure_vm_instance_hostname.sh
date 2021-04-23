#!/bin/sh -eux
# configure the hostname of an azure vm instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] azure vm hostname config parameters [w/ defaults].
azurerm_vm_hostname="${azurerm_vm_hostname:-apm}"
azurerm_vm_domain="${azurerm_vm_domain:-localdomain}"

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${azurerm_vm_hostname}.${azurerm_vm_domain}" --static
hostnamectl set-hostname "${azurerm_vm_hostname}.${azurerm_vm_domain}"

# verify configuration.
hostnamectl status

# modify system network configuration. -------------------------------------------------------------
network_config_file="/etc/sysconfig/network"

if [ -f "$network_config_file" ]; then
  cp -p $network_config_file ${network_config_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c '^HOSTNAME' "$network_config_file") -eq 0 ]; then
    echo "HOSTNAME=${azurerm_vm_hostname}.${azurerm_vm_domain}" >> ${network_config_file}
  else
    sed -i -e "/^HOSTNAME/s/^.*$/HOSTNAME=${azurerm_vm_hostname}.${azurerm_vm_domain}/" ${network_config_file}
  fi

  # verify configuration.
  grep '^HOSTNAME' "$network_config_file"
fi

# modify system hosts file. ------------------------------------------------------------------------
system_hosts_file="/etc/hosts"

if [ -f "$system_hosts_file" ]; then
  cp -p $system_hosts_file ${system_hosts_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c "${azurerm_vm_hostname}" "$system_hosts_file") -eq 0 ]; then
    sed -i -e "1i\127.0.0.1   ${azurerm_vm_hostname}.${azurerm_vm_domain} ${azurerm_vm_hostname}" ${system_hosts_file}
  else
    sed -i -e "/${azurerm_vm_hostname}/s/^.*$/127.0.0.1   ${azurerm_vm_hostname}.${azurerm_vm_domain} ${azurerm_vm_hostname}/" ${system_hosts_file}
  fi

  # verify configuration.
  grep "$azurerm_vm_hostname" "$system_hosts_file"
fi

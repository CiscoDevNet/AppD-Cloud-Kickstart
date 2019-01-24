#!/bin/sh -eux
# configure the hostname on amazon linux 2.

# set default values for input environment variables if not set. ---------------
aws_hostname="${aws_hostname:-apm}"     # [optional] aws hostname (defaults to 'apm').

# set the system hostname. -----------------------------------------------------
hostnamectl set-hostname "${aws_hostname}.localdomain" --static
hostnamectl set-hostname "${aws_hostname}.localdomain"

# verify configuration.
hostnamectl status

# modify system network configuration. -----------------------------------------
network_config_file="/etc/sysconfig/network"

if [ -f "$network_config_file" ]; then
  cp -p $network_config_file ${network_config_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c '^HOSTNAME' "$network_config_file") -eq 0 ]; then
    echo "HOSTNAME=${aws_hostname}.localdomain" >> ${network_config_file}
  else
    sed -i -e "/^HOSTNAME/s/^.*$/HOSTNAME=${aws_hostname}.localdomain/" ${network_config_file}
  fi

  # verify configuration.
  grep '^HOSTNAME' "$network_config_file"
fi

# modify system hosts file. ----------------------------------------------------
system_hosts_file="/etc/hosts"

if [ -f "$system_hosts_file" ]; then
  cp -p $system_hosts_file ${system_hosts_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c "${aws_hostname}" "$system_hosts_file") -eq 0 ]; then
    sed -i -e "1i\127.0.0.1   ${aws_hostname} ${aws_hostname}.localdomain" ${system_hosts_file}
  else
    sed -i -e "/${aws_hostname}/s/^.*$/127.0.0.1   ${aws_hostname} ${aws_hostname}.localdomain/" ${system_hosts_file}
  fi

  # verify configuration.
  grep "$aws_hostname" "$system_hosts_file"
fi

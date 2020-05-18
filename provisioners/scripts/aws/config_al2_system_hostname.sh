#!/bin/sh -eux
# configure the hostname of an aws ec2 instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws ec2 hostname config parameters [w/ defaults].
aws_ec2_hostname="${aws_ec2_hostname:-apm}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${aws_ec2_hostname}.${aws_ec2_domain}" --static
hostnamectl set-hostname "${aws_ec2_hostname}.${aws_ec2_domain}"

# verify configuration.
hostnamectl status

# modify system network configuration. -------------------------------------------------------------
network_config_file="/etc/sysconfig/network"

if [ -f "$network_config_file" ]; then
  cp -p $network_config_file ${network_config_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c '^HOSTNAME' "$network_config_file") -eq 0 ]; then
    echo "HOSTNAME=${aws_ec2_hostname}.${aws_ec2_domain}" >> ${network_config_file}
  else
    sed -i -e "/^HOSTNAME/s/^.*$/HOSTNAME=${aws_ec2_hostname}.${aws_ec2_domain}/" ${network_config_file}
  fi

  # verify configuration.
  grep '^HOSTNAME' "$network_config_file"
fi

# modify system hosts file. ------------------------------------------------------------------------
system_hosts_file="/etc/hosts"

if [ -f "$system_hosts_file" ]; then
  cp -p $system_hosts_file ${system_hosts_file}.orig

  # set the 'hostname' entry if not set.
  if [ $(grep -c "${aws_ec2_hostname}" "$system_hosts_file") -eq 0 ]; then
    sed -i -e "1i\127.0.0.1   ${aws_ec2_hostname}.${aws_ec2_domain} ${aws_ec2_hostname}" ${system_hosts_file}
  else
    sed -i -e "/${aws_ec2_hostname}/s/^.*$/127.0.0.1   ${aws_ec2_hostname}.${aws_ec2_domain} ${aws_ec2_hostname}/" ${system_hosts_file}
  fi

  # verify configuration.
  grep "$aws_ec2_hostname" "$system_hosts_file"
fi

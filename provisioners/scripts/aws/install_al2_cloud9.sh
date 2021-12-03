#!/bin/sh -eux
# install cloud9 binaries for aws amazon linux 2 vms.

# set default values for input environment variables if not set. -----------------------------------
user_name="${user_name:-}"

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with correct privilege for the given user name.
  Example:
    [root]# export user_name="ec2-user"                         # user name.
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$user_name" ]; then
  echo "Error: 'user_name' environment variable not set."
  usage
  exit 1
fi

if [ "$user_name" == "root" ]; then
  echo "Error: 'user_name' should NOT be 'root'."
  usage
  exit 1
fi

# install cloud9 runtime enviroment if os is 'amazon linux 2'. -------------------------------------
user_host_os=$(hostnamectl | awk '/Operating System/ {printf "%s %s %s", $3, $4, $5}')
if [ "$user_host_os" == "Amazon Linux 2" ]; then
  runuser -c "${kickstart_home}/provisioners/scripts/aws/c9-install.sh" - ${user_name}
fi

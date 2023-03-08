#!/bin/sh -eux
# install ansible 2.x with pip3 linux 202x.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] ansible 2.x install parameters [w/ defaults].
user_name="${user_name:-ec2-user}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_name="ec2-user"                         # user name.
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

# install ansible. ---------------------------------------------------------------------------------
# install and upgrade ansible in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install ansible --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install --upgrade ansible --user" - ${user_name}

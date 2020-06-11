#!/bin/sh -eux
# create new group on centos linux 7.x.

# set empty default values for group env variables if not set. -------------------------------------
group_name="${group_name:-}"
group_id="${group_id:-}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export group_name="group1"                      # group name.
    [root]# export group_id="1001"                          # [optional] group id.
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$group_name" ]; then
  echo "Error: 'group_name' environment variable not set."
  usage
  exit 1
fi

# check if group already exists. -------------------------------------------------------------------
if [ "$(getent group ${group_name})" ]; then
  exit 0
fi

# create group. ------------------------------------------------------------------------------------
# check for custom group id.
if [ -n "$group_id" ]; then
  groupadd -g ${group_id} ${group_name}
else
  groupadd ${group_name}
fi

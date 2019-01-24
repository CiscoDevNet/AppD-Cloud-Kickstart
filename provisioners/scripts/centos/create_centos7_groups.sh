#!/bin/sh -eux
# create new groups on centos linux 7.x.

# set empty default values for group env variables if not set. -----------------
group_names="${group_names:-}"                              # whitespace separated list of group names.
group_ids="${group_ids:-}"                                  # [optional] whitespace separated list of group ids.

# define usage function. -------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export group_names="group1 group2 group3"       # whitespace separated list of group names.
    [root]# export group_ids="1001 1002 1003"               # [optional] whitespace separated list of group ids.
    [root]# $0
EOF
}

# validate environment variables. ----------------------------------------------
if [ -z "$group_names" ]; then
  echo "Error: 'group_names' environment variable not set."
  usage
  exit 1
fi

# initialize group name and id arrays. -----------------------------------------
group_names_array=( $group_names )
group_names_length=${#group_names_array[@]}
group_ids_array=( $group_ids )
group_ids_length=${#group_ids_array[@]}

# if group ids are present, do the number of group names and ids match?
if [ -n "$group_ids" ]; then
  if [ ! "$group_names_length" -eq "$group_ids_length" ];then
    echo "Error: Number of 'group_names' and 'group_ids' must be equal."
    usage
    exit 1
  fi
fi

# loop to create each group. ---------------------------------------------------
ii=0                                                        # initialize array index.
for group_name in "${group_names_array[@]}"; do
  # check for custom group ids.
  if [ -n "$group_ids" ]; then
    groupadd -g ${group_ids_array[$ii]} ${group_name}
  else
    groupadd ${group_name}
  fi

  ii=$(($ii + 1))                                           # increment array index.
done

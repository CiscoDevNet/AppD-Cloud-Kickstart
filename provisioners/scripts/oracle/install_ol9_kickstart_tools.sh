#!/bin/sh -eux
# install useful command-line developer tools on oracle linux 9.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] developer tools install parameters [w/ defaults].
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

# install epel repository. -------------------------------------------------------------------------
dnf -y install epel-release

# enable powertools repository. --------------------------------------------------------------------
dnf config-manager --set-enabled ol9_codeready_builder
dnf repolist

# install neofetch system information tool. ---------------------------------------------------------
dnf -y install neofetch

# verify installation.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
neofetch --version
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# display system information.
neofetch

# install git. -------------------------------------------------------------------------------------
dnf -y install git
git --version

#!/bin/sh -eux
# install useful command-line developer tools on centos 8.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] developer tools install parameters [w/ defaults].
user_name="${user_name:-centos}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_name="centos"                           # user name.
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
dnf config-manager --set-enabled powertools
dnf repolist

# install neofetch system information tool. ---------------------------------------------------------
dnf -y install neofetch

# verify installation.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
neofetch --version
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# display system information.
neofetch

# install python 2.x, pip2, and setuptools. ---------------------------------------------------------
# install python2.
dnf -y install python2
python2 --version

# install pip2.
dnf -y install python2-pip
pip2 --version

# upgrade pip2 in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip2 install pip --upgrade --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip2 --version" - ${user_name}

# install python 2.x setup tools.
dnf -y install python2-setuptools

# upgrade setuptools in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip2 install --upgrade setuptools --user" - ${user_name}

# install pip 2.x wheel.
# install and upgrade wheel in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip2 install wheel --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip2 install --upgrade wheel --user" - ${user_name}

# install python 2.x as the default. ---------------------------------------------------------------
alternatives --set python /usr/bin/python2
python --version

# install git. -------------------------------------------------------------------------------------
dnf -y install git
git --version

#!/bin/sh -eux
# install python 3.x for centos 8.x.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] python 3.x install parameters [w/ defaults].
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

# install python 3.x, pip3, and setuptools. ---------------------------------------------------------
# install python3.
dnf -y install python3
python3 --version

# install pip3.
dnf -y install python3-pip
pip3 --version

# upgrade pip3 in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install pip --upgrade --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 --version" - ${user_name}

# install python 3.x setup tools.
dnf -y install python3-setuptools

# upgrade setuptools in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install --upgrade setuptools --user" - ${user_name}

# install pip 3.x wheel.
# install and upgrade wheel in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install wheel --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install --upgrade wheel --user" - ${user_name}

# install python 3.x as the default. ---------------------------------------------------------------
alternatives --set python /usr/bin/python3
python --version

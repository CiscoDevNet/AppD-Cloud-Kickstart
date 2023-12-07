#!/bin/sh -eux
# install useful command-line developer tools on ubuntu linux.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] developer tools install parameters [w/ defaults].
user_name="${user_name:-ubuntu}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_name="ubuntu"                           # user name.
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

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install python 2.x. ------------------------------------------------------------------------------
# retrieve ubuntu release version.
ubuntu_release=$(lsb_release -rs)

# modify python 2.x installation command based on ubuntu release.
if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
    # install python 2.x, pip2, and setuptools.
    16.04|18.04)
      # install python2.
      apt-get -y install python
      python --version

      # install pip2.
      apt-get -y install python-pip
      pip --version

      # upgrade pip2 in the user's home account.
      runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip install pip --upgrade --user" - ${user_name}
      runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip --version" - ${user_name}

      # install python 2.x setup tools.
      apt-get -y install python-setuptools

      # upgrade setuptools in the user's home account.
      runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip install --upgrade setuptools --user" - ${user_name}

      # install pip 2.x wheel.
      # install and upgrade wheel in the user's home account.
      runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip install wheel --user" - ${user_name}
      runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip install --upgrade wheel --user" - ${user_name}
      ;;

    # install python 2.x only.
    20.04|22.04)
      # install python2.
      apt-get -y install python2
      python2 --version
      ;;

    # skip python 2.x installation.
    23.04|23.10)
      ;;

    *)
      echo "Error: Python2 installation NOT supported on Ubuntu release: '$(lsb_release -ds)'."
      exit 1
      ;;
  esac
fi

# modify python 3.x installation command based on ubuntu release.
if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
    23.04|23.10)
      apt-get -y install python3
      apt-get -y install python3-pip
      apt-get -y install python3-full
      python3 --version
      pip3 --version

      apt-get -y install python3-setuptools
      apt-get -y install python3-wheel
      ;;
  esac
fi

# install additional developer tools. --------------------------------------------------------------
apt-get -y install curl git tree wget unzip man net-tools debconf-utils

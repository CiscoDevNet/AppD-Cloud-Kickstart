#!/bin/sh -eux
# install useful command-line developer tools on ubuntu linux.

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install python 2.x. ------------------------------------------------------------------------------
# retrieve ubuntu release version.
ubuntu_release=$(lsb_release -rs)

# modify python 2.x installation command based on ubuntu release.
if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
      16.04|18.04)
        apt_get_install_python2_cmd="apt-get -y install python"
        python2_version_cmd="python --version"
        ;;
      20.04|22.04|22.10)
        apt_get_install_python2_cmd="apt-get -y install python2"
        python2_version_cmd="python2 --version"
        ;;
      *)
        echo "Error: Python2 installation NOT supported on Ubuntu release: '$(lsb_release -ds)'."
        exit 1
        ;;
  esac
fi

# install python 2.x and verify the version.
eval ${apt_get_install_python2_cmd}
eval ${python2_version_cmd}

# install pip3 and setuptools. ---------------------------------------------------------------------
apt-get -y install python3-pip
pip3 --version

# install python 2.x setup tools.
apt-get -y install python-setuptools
#pip install --upgrade setuptools
#easy_install --version

# install additional developer tools. --------------------------------------------------------------
apt-get -y install curl git tree wget unzip man net-tools debconf-utils

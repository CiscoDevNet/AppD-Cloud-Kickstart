#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Python 3.8 for Oracle Linux 7.9.
#
# Python is a clear and powerful object-oriented programming language that lets you work quickly
# and integrate systems more effectively. Some of Python's notable features include:
#
#   - Uses an elegant syntax, making the programs you write easier to read.
#   - Is an easy-to-use language that makes it simple to get your program working. This makes
#     Python ideal for prototype development and other ad-hoc programming tasks.
#   - Comes with a large standard library that supports many common programming tasks such as
#     connecting to web servers, searching text with regular expressions, reading and modifying
#     files.
#   - Python's interactive mode makes it easy to test short snippets of code.
#
# For more details, please visit:
#   https://www.python.org/
#   https://www.python.org/doc/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] python 3.x install parameters [w/ defaults].
user_name="${user_name:-ec2-user}"

# prepare yum packages. ----------------------------------------------------------------------------
yum -y install oracle-epel-release-el7
yum-config-manager --enable ol7_developer_EPEL

yum -y groupinstall "Development Tools"
yum -y install openssl-devel bzip2-devel libffi-devel xz-devel

# remove existing python3 installation.
#yum -y remove python3

# install python3 binaries from source. ------------------------------------------------------------
python3_home="python3"
python3_release="3.8.18"
python3_folder="Python-${python3_release}"
python3_binary="${python3_folder}.tgz"

# create python3 source parent folder.
mkdir -p /usr/local/src/${python3_home}
cd /usr/local/src/${python3_home}

# download python3 source from python.org.
curl --silent --location https://www.python.org/ftp/python/${python3_release}/${python3_binary} --output ${python3_binary}

# extract python3 source.
rm -Rf ${python3_folder}
tar -zxvf ${python3_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${python3_folder}
rm -f ${python3_binary}

# build and install python3 binaries.
cd ${python3_folder}
./configure --enable-optimizations --prefix=/usr
make altinstall

# create alternative symbolic links.
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${python3_release:0:3} 1
update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip${python3_release:0:3} 1
update-alternatives --list

# set python3 home environment variables.
PATH=/usr/bin:$PATH
export PATH

# verify installation.
python3 --version
pip3 --version

# upgrade pip3 and setuptools, etc. ----------------------------------------------------------------
# upgrade pip3 in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install pip --upgrade --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 --version" - ${user_name}

# upgrade setuptools in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install setuptools --upgrade --user" - ${user_name}

# install python 3.9 wheel.
# install and upgrade wheel in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install wheel --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install wheel --upgrade --user" - ${user_name}

# install python 3.9 lxml xml and html python library.
# install and upgrade lxml in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install lxml --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} python3 -m pip install lxml --upgrade --user" - ${user_name}

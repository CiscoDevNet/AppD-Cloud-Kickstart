#!/bin/sh -eux
# install python 3.x for centos 7.x.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] python 3.x install parameters [w/ defaults].
user_name="${user_name:-centos}"

# install python 3.x. ------------------------------------------------------------------------------
yum -y install python3

# verify installation.
python3 --version
pip3 --version

# upgrade python 3.x pip. --------------------------------------------------------------------------
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 install pip --upgrade --user" - ${user_name}
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} pip3 --version" - ${user_name}

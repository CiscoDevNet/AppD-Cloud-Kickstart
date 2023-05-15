#!/bin/sh -eux
# install python 3.8 and pip 3.8 on amazon linux 2.

# install python 3.8 and tools. --------------------------------------------------------------------
amazon-linux-extras install -y python3.8

# update symbolic links to new version.
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2
python3 --version

# update 'root' path environment variable.
PATH=/usr/local/bin:$PATH
export PATH

# upgrade python 3.8 pip and setup tools.
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools

# install html and xml python libraries.
python3 -m pip install --upgrade lxml

# verify installation.
pip --version
pip3 --version
#easy_install --version

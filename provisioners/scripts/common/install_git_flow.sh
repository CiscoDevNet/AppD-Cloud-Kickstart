#!/bin/sh -eux
# install git flow (avh edition) extensions to git.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] git flow install parameters [w/ defaults].
user_name="${user_name:-centos}"                                # user name.
user_group="${user_group:-centos}"                              # user login group.

# install git-flow binaries from source. -----------------------------------------------------------
# create git-flow source parent folder.
mkdir -p /usr/local/src/git
cd /usr/local/src/git

# retrieve git-flow installer from github.com.
rm -f gitflow-installer.sh
wget --no-verbose --no-check-certificate https://github.com/petervanderdoes/gitflow-avh/raw/develop/contrib/gitflow-installer.sh
chmod 755 gitflow-installer.sh

# create git-flow binary parent folder.
mkdir -p /usr/local/git/gitflow/bin

# build and install git-flow binaries.
PREFIX=/usr/local/git/gitflow
export PREFIX

./gitflow-installer.sh install stable

# set git-flow home environment variables.
GIT_FLOW_HOME=/usr/local/git/gitflow
export GIT_FLOW_HOME
PATH=${GIT_FLOW_HOME}/bin:$PATH
export PATH

# verify installation.
git flow version

# install git-flow completion for bash. ------------------------------------------------------------
gfcbin=".git-flow-completion.bash"
gfcfolder="/home/${user_name}"

# download git-flow completion for bash from github.com.
rm -f ${gfcfolder}/${gfcbin}
curl --silent --location "https://raw.githubusercontent.com/petervanderdoes/git-flow-completion/develop/git-flow-completion.bash" --output ${gfcfolder}/${gfcbin}
chown -R ${user_name}:${user_group} ${gfcfolder}/${gfcbin}
chmod 644 ${gfcfolder}/${gfcbin}

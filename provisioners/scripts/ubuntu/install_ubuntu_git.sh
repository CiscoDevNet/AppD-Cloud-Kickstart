#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Git distributed version control system.
#
# Git is a fast, scalable, distributed revision control system with an unusually rich command set
# that provides both high-level operations and full access to internals.
#
# For more details, please visit:
#   https://git-scm.com/
#   https://github.com/git/git/blob/master/INSTALL
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] git flow install parameters [w/ defaults].
user_name="${user_name:-ubuntu}"                                # user name.
user_group="${user_group:-ubuntu}"                              # user login group.

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install tools needed to build git from source. ---------------------------------------------------
apt-get -y install libz-dev libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc

# install git binaries from source. ----------------------------------------------------------------
git_home="git"
git_release="2.49.0"
git_folder="git-${git_release}"
git_binary="${git_folder}.tar.gz"

# create git source parent folder.
mkdir -p /usr/local/src/git
cd /usr/local/src/git

# download git source from kernel.org.
curl --silent --location https://mirrors.edge.kernel.org/pub/software/scm/git/${git_binary} --output ${git_binary}

# extract git source.
rm -Rf ${git_folder}
tar -zxvf ${git_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${git_folder}
rm -f ${git_binary}

# build and install git binaries.
cd ${git_folder}
#CFLAGS="-DNO_UNCOMPRESS2"
#export CFLAGS

./configure
make prefix=/usr/local/git/${git_folder} all
make prefix=/usr/local/git/${git_folder} install

# create soft link to git binary.
cd /usr/local/git
rm -f ${git_home}
ln -s ${git_folder} ${git_home}

# set git home environment variables.
GIT_HOME=/usr/local/git/${git_home}
export GIT_HOME
PATH=${GIT_HOME}/bin:$PATH
export PATH

# verify installation.
git --version

# install git man pages. ---------------------------------------------------------------------------
gitmanbinary="git-manpages-${git_release}.tar.gz"

# create git man pages parent folder if needed.
mkdir -p /usr/share/man
cd /usr/share/man

# download git man pages from kernel.org.
curl --silent --location https://mirrors.edge.kernel.org/pub/software/scm/git/${gitmanbinary} --output ${gitmanbinary}

# extract git man pages.
tar -zxvf ${gitmanbinary} --no-same-owner --no-overwrite-dir
rm -f ${gitmanbinary}

# install git completion for bash. -----------------------------------------------------------------
gcbin=".git-completion.bash"
gcfolder="/home/${user_name}"

# download git completion for bash from github.com.
rm -f ${gcfolder}/${gcbin}
curl --silent --location "https://raw.githubusercontent.com/git/git/v${git_release}/contrib/completion/git-completion.bash" --output ${gcfolder}/${gcbin}

chown -R ${user_name}:${user_group} ${gcfolder}/${gcbin}
chmod 644 ${gcfolder}/${gcbin}

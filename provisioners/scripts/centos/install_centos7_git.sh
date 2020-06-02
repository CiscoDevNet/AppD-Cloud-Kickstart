#!/bin/sh -eux
# install git distributed version control system.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] git flow install parameters [w/ defaults].
user_name="${user_name:-centos}"                                # user name.
user_group="${user_group:-centos}"                              # user login group.

# install tools needed to build git from source. ---------------------------------------------------
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
yum -y install gcc perl-ExtUtils-MakeMaker

# install git binaries from source. ----------------------------------------------------------------
githome="git"
gitrelease="2.27.0"
gitfolder="git-${gitrelease}"
gitbinary="${gitfolder}.tar.gz"

# create git source parent folder.
mkdir -p /usr/local/src/git
cd /usr/local/src/git

# download git source from kernel.org.
wget --no-verbose https://www.kernel.org/pub/software/scm/git/${gitbinary}

# extract git source.
tar -zxvf ${gitbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${gitfolder}
rm -f ${gitbinary}

# create git binary parent folder.
mkdir -p /usr/local/git/${gitfolder}

# build and install git binaries.
cd ${gitfolder}
make prefix=/usr/local/git/${gitfolder} all
make prefix=/usr/local/git/${gitfolder} install

# create soft link to git binary.
cd /usr/local/git
rm -f ${githome}
ln -s ${gitfolder} ${githome}

# set git home environment variables.
GIT_HOME=/usr/local/git/${githome}
export GIT_HOME
PATH=${GIT_HOME}/bin:$PATH
export PATH

# verify installation.
git --version

# install git man pages. ---------------------------------------------------------------------------
gitmanbinary="git-manpages-${gitrelease}.tar.gz"

# create git man pages parent folder if needed.
mkdir -p /usr/share/man
cd /usr/share/man

# download git man pages from kernel.org.
wget --no-verbose https://www.kernel.org/pub/software/scm/git/${gitmanbinary}

# extract git man pages.
tar -zxvf ${gitmanbinary} --no-same-owner --no-overwrite-dir
rm -f ${gitmanbinary}

# install git completion for bash. -----------------------------------------------------------------
gcbin=".git-completion.bash"
gcfolder="/home/${user_name}"

# download git completion for bash from github.com.
rm -f ${gcfolder}/${gcbin}
curl --silent --location "https://raw.githubusercontent.com/git/git/v${gitrelease}/contrib/completion/git-completion.bash" --output ${gcfolder}/${gcbin}

chown -R ${user_name}:${user_group} ${gcfolder}/${gcbin}
chmod 644 ${gcfolder}/${gcbin}

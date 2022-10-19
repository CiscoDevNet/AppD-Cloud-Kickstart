#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Vim 9 - Vi IMproved, a programmer's text editor.
#
# Vim is a text editor that is upwards compatible to Vi. It can be used to edit all kinds
# of plain text. It is especially useful for editing programs.
#
# There are a lot of enhancements above Vi: multi level undo, multi windows and buffers,
# syntax highlighting, command line editing, filename completion, on-line help, visual
# selection, etc. See ":help vi_diff.txt" for a summary of the differences between Vim and Vi.
#
# While running Vim a lot of help can be obtained from the on-line help system, with the
# ":help" command.
#
# For more details, please visit:
#   https://www.vim.org/
#   https://github.com/vim/vim
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install tools needed to build vim from source. ---------------------------------------------------
apt-get -y install make clang libtool-bin

# install vim binaries from source. ----------------------------------------------------------------
# create vim source parent folder.
mkdir -p /usr/local/src
cd /usr/local/src

# set environment variables.
GIT_HOME=/usr/local/git/git
export GIT_HOME
PATH=${GIT_HOME}/bin:/usr/local/bin:$PATH
export PATH

# download vim source from github.com.
rm -Rf ./vim
git clone https://github.com/vim/vim.git
cd vim
git fetch origin

# build and install vim binaries.
./configure --with-features=huge --enable-multibyte --enable-rubyinterp --enable-python3interp --enable-perlinterp
make
make install

# set vim home environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
vim --version | awk 'FNR < 3 {print $0}'

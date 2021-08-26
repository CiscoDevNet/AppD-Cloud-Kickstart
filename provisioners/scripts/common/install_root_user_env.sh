#!/bin/sh -eux
# create default command-line environment profile for appdynamics cloud kickstart 'root' user.

# set default values for input environment variables if not set. -----------------------------------
user_name="root"                                                # user name for 'root' user.
user_group="root"                                               # user login group for 'root' user.
user_home="/root"                                               # user home for 'root' user.
user_prompt_color="red"                                         # user prompt color (defaults to 'red').
                                                                #   valid colors:
                                                                #     'black', 'blue', 'cyan', 'green', 'magenta', 'red', 'white', 'yellow'

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# create default environment profile for the user. -------------------------------------------------
root_bashprofile="${kickstart_home}/provisioners/scripts/common/users/user-root-bash_profile.sh"
root_bashrc="${kickstart_home}/provisioners/scripts/common/users/user-root-bashrc.sh"

# copy environment profiles to user home.
cd ${user_home}
cp -p .bash_profile .bash_profile.orig
cp -p .bashrc .bashrc.orig

cp -f ${root_bashprofile} .bash_profile
cp -f ${root_bashrc} .bashrc

# set user prompt color.
sed -i "s/{red}/{${user_prompt_color}}/g" .bashrc

# remove existing vim profile if it exists. --------------------------------------------------------
if [ -d ".vim" ]; then
  rm -Rf ./.vim
fi

cp -f ${kickstart_home}/provisioners/scripts/common/tools/vim-files.tar.gz .
tar -zxvf vim-files.tar.gz --no-same-owner --no-overwrite-dir
rm -f vim-files.tar.gz

# configure the vim profile. -----------------------------------------------------------------------
# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# rename the vimrc folder if it exists.
vimrc_home="${user_home}/.vim"
if [ -d "$vimrc_home" ]; then
  # rename the folder using the current date.
  mv ${vimrc_home} ${user_home}/vim.${curdate}.orig
fi

# set vim home environment variables.
TERM=xterm-256color
export TERM
PATH=/usr/local/bin:$PATH
export PATH

# create vimrc local to override default vim configuration.
vimrc_local="${user_home}/.vimrc.local"
if [ -f "$vimrc_local" ]; then
  # rename the folder using the current date.
  mv ${vimrc_local} ${user_home}/vimrc_local.${curdate}.orig
fi

# create temporary vimrc local to fix issue during install with snipmate parser.
cat <<EOF > ${vimrc_local}
" Temporary override of default Vim resource configuration.
let g:snipMate = {'snippet_version': 1} " Use the new version of the SnipMate parser.
EOF
chown ${user_name}:${user_group} ${vimrc_local}

# download and install useful vim configuration based on developer pair stations at pivotal labs.
git clone https://github.com/pivotal-legacy/vim-config.git ${user_home}/.vim

###### vundle installer bug fix. ------------------------------------------------------------------------
###### append the bug fix into the vundle install script.
#####vundle_install_file="${user_home}/.vim/bin/install"
#####if [ -f "$vundle_install_file" ]; then
#####  # copy the original file using the current date.
#####  cp -p ${vundle_install_file} ${vundle_install_file}.${curdate}.orig
#####
#####  # append 'sed' script to fix the error in the '02tlib.vim' file.
#####  vim_file="${user_home}/.vim/bundle/tlib_vim/plugin/02tlib.vim"
#####  echo "" >> "${vundle_install_file}"
#####  echo "# fix error in 'TBrowseScriptnames' command argument syntax." >> "${vundle_install_file}"
#####  echo "# replaces: '-nargs=0' --> '-nargs=1' in original command." >> "${vundle_install_file}"
#####  echo "# original: command! -nargs=0 -complete=command TBrowseScriptnames call tlib#cmd#TBrowseScriptnames()" >> "${vundle_install_file}"
#####  echo "sed -i \"s/-nargs=0/-nargs=1/g\" ${vim_file}" >> "${vundle_install_file}"
#####fi

# run the vundle install script. -------------------------------------------------------------------
${user_home}/.vim/bin/install

# create final vimrc local file. -------------------------------------------------------------------
rm -f ${vimrc_local}
cat <<EOF > ${vimrc_local}
" Override default Vim resource configuration.
colorscheme triplejelly                 " Set colorscheme to 'triplejelly'. Default is 'Tomorrow-Night'.
set nofoldenable                        " Turn-off folding of code files. To toggle on/off: use 'zi'.
let g:vim_json_syntax_conceal = 0       " Turn-off concealing of double quotes in 'vim-json' plugin.
let g:snipMate = {'snippet_version': 1} " Use the new version of the SnipMate parser.

" Autoclose 'NERDTree' plugin if it's the only open window left.
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
EOF
chown ${user_name}:${user_group} ${vimrc_local}

# initialize the vim plugin manager by opening vim to display the color scheme.
vim -c colorscheme -c quitall

# set directory ownership and file permissions. ----------------------------------------------------
chown -R ${user_name}:${user_group} .
chmod 644 .bash_profile .bashrc

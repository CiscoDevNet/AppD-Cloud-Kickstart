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

# set user prompt color.
sed -i "s/{red}/{${user_prompt_color}}/g" ${root_bashrc}

# copy environment profiles to user home.
cd ${user_home}
cp -p .bash_profile .bash_profile.orig
cp -p .bashrc .bashrc.orig

cp -f ${root_bashprofile} .bash_profile
cp -f ${root_bashrc} .bashrc

# remove existing vim profile if it exists.
if [ -d ".vim" ]; then
  rm -Rf ./.vim
fi

cp -f ${kickstart_home}/provisioners/scripts/common/tools/vim-files.tar.gz .
tar -zxvf vim-files.tar.gz --no-same-owner --no-overwrite-dir
rm -f vim-files.tar.gz

chown -R ${user_name}:${user_group} .
chmod 644 .bash_profile .bashrc

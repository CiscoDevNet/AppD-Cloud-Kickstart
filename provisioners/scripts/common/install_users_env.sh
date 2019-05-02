#!/bin/sh -eux
# create default command-line environment profiles for appdynamics cloud kickstart users.

# set default values for input environment variables if not set. -----------------------------------
user_name="${user_name:-ec2-user}"                              # [optional] user name (defaults to 'ec2-user').
user_group="${user_group:-ec2-user}"                            # [optional] user login group (defaults to 'ec2-user').
user_home="${user_home:-/home/$user_name}"                      # [optional] user home (defaults to '/home/ec2-user').
d_completion_release="${d_completion_release:-18.06.1-ce}"      # [optional] docker completion for bash release (defaults to '18.06.1-ce').
dc_completion_release="${dc_completion_release:-1.24.0}"        # [optional] docker compose completion for bash release (defaults to '1.24.0').

# set default value for appdynamics cloud kickstart home environment variable if not set. ----------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# create default environment profile for user 'root'. ----------------------------------------------
root_profile="${kickstart_home}/provisioners/scripts/common/users/user-root-bash_profile.sh"
root_rc="${kickstart_home}/provisioners/scripts/common/users/user-root-bashrc.sh"

# copy environment profiles to user 'root' home.
cd /root
cp -p .bash_profile .bash_profile.orig
cp -p .bashrc .bashrc.orig

cp -f ${root_profile} .bash_profile
cp -f ${root_rc} .bashrc

# remove existing vim profile if it exists.
if [ -d ".vim" ]; then
  rm -Rf ./.vim
fi

cp -f ${kickstart_home}/provisioners/scripts/common/tools/vim-files.tar.gz .
tar -zxvf vim-files.tar.gz --no-same-owner --no-overwrite-dir
rm -f vim-files.tar.gz

chown -R root:root .
chmod 644 .bash_profile .bashrc

# create default environment profile for the user. -------------------------------------------------
user_bashprofile="${kickstart_home}/provisioners/scripts/common/users/user-kickstart-bash_profile.sh"
user_bashrc="${kickstart_home}/provisioners/scripts/common/users/user-kickstart-bashrc.sh"

# copy environment profiles to user home.
cd ${user_home}
cp -p .bash_profile .bash_profile.orig
cp -p .bashrc .bashrc.orig

cp -f ${user_bashprofile} .bash_profile
cp -f ${user_bashrc} .bashrc

# remove existing vim profile if it exists.
if [ -d ".vim" ]; then
  rm -Rf ./.vim
fi

cp -f ${kickstart_home}/provisioners/scripts/common/tools/vim-files.tar.gz .
tar -zxvf vim-files.tar.gz --no-same-owner --no-overwrite-dir
rm -f vim-files.tar.gz

chown -R ${user_name}:${user_group} .
chmod 644 .bash_profile .bashrc

# create docker profile for the user. --------------------------------------------------------------
# add user to the 'docker' group.
usermod -aG docker ${user_name}

# install docker completion for bash.
d_completion_binary=".docker-completion.sh"

# download docker completion for bash from github.com.
rm -f ${user_home}/${d_completion_binary}
curl --silent --location "https://github.com/docker/cli/raw/v${d_completion_release}/contrib/completion/bash/docker" --output ${user_home}/${d_completion_binary}
chown -R ${user_name}:${user_group} ${user_home}/${d_completion_binary}
chmod 644 ${user_home}/${d_completion_binary}

# install docker compose completion for bash.
dc_completion_binary=".docker-compose-completion.sh"

# download docker completion for bash from github.com.
rm -f ${user_home}/${dc_completion_binary}
curl --silent --location "https://github.com/docker/compose/raw/${dc_completion_release}/contrib/completion/bash/docker-compose" --output ${user_home}/${dc_completion_binary}
chown -R ${user_name}:${user_group} ${user_home}/${dc_completion_binary}
chmod 644 ${user_home}/${dc_completion_binary}

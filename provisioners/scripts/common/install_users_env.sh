#!/bin/sh -eux
# create default command-line environment profiles for appdynamics cloud kickstart users.

# set default value for appdynamics cloud kickstart home environment variable if not set. ----------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"    # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

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

# create default environment profile for user 'ec2-user'. ------------------------------------------
ec2user_profile="${kickstart_home}/provisioners/scripts/common/users/user-ec2-user-bash_profile.sh"
ec2user_rc="${kickstart_home}/provisioners/scripts/common/users/user-ec2-user-bashrc.sh"

# copy environment profiles to user 'ec2-user' home.
cd /home/ec2-user
cp -p .bash_profile .bash_profile.orig
cp -p .bashrc .bashrc.orig

cp -f ${ec2user_profile} .bash_profile
cp -f ${ec2user_rc} .bashrc

# remove existing vim profile if it exists.
if [ -d ".vim" ]; then
  rm -Rf ./.vim
fi

cp -f ${kickstart_home}/provisioners/scripts/common/tools/vim-files.tar.gz .
tar -zxvf vim-files.tar.gz --no-same-owner --no-overwrite-dir
rm -f vim-files.tar.gz

chown -R ec2-user:ec2-user .
chmod 644 .bash_profile .bashrc

# create docker profile for the user. --------------------------------------------------------------
# add user 'ec2-user' to the 'docker' group.
usermod -aG docker ec2-user

# install docker completion for bash.
dcompletion_release="18.09.0"
dcompletion_binary=".docker-completion.sh"
userfolder="/home/ec2-user"

# download docker completion for bash from github.com.
rm -f ${userfolder}/${dcompletion_binary}
curl --silent --location "https://github.com/docker/cli/raw/v${dcompletion_release}/contrib/completion/bash/docker" --output ${userfolder}/${dcompletion_binary}
chown -R ec2-user:ec2-user ${userfolder}/${dcompletion_binary}
chmod 644 ${userfolder}/${dcompletion_binary}

# install docker compose completion for bash.
dcrelease="1.23.2"
dccompletion_binary=".docker-compose-completion.sh"

# download docker completion for bash from github.com.
rm -f ${userfolder}/${dccompletion_binary}
curl --silent --location "https://github.com/docker/compose/raw/${dcrelease}/contrib/completion/bash/docker-compose" --output ${userfolder}/${dccompletion_binary}
chown -R ec2-user:ec2-user ${userfolder}/${dccompletion_binary}
chmod 644 ${userfolder}/${dccompletion_binary}

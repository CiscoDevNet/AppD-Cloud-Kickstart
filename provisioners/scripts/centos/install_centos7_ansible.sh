#!/bin/sh -eux
# install ansible on centos linux 7.x.

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos
cd ${kickstart_home}/provisioners/scripts/centos

# install ansible. ---------------------------------------------------------------------------------
ansible_release="2.9.16-1"
ansible_binary="ansible-${ansible_release}.el7.ans.noarch.rpm"

# download ansible repository.
rm -f ${ansible_binary}
wget --no-verbose https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/${ansible_binary}

# install ansible. ---------------------------------------------------------------------------------
yum -y install ${ansible_binary}

# verify ansible installation.
ansible --version
